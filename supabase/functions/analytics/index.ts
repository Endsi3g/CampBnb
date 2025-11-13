// ============================================
// Campbnb Québec - Edge Function: Analytics API
// ============================================
// Gestion des analytics et événements utilisateur

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const endpoint = pathParts[pathParts.length - 1]

    // POST /analytics/event - Enregistrer un événement
    if (req.method === 'POST' && endpoint === 'event') {
      const body = await req.json()
      const {
        event_name,
        event_category,
        event_type,
        screen_name,
        event_properties,
        session_id,
        anonymous_id,
        app_version,
        platform,
        os_version,
        device_model,
        city,
        province,
      } = body

      if (!event_name || !event_category || !event_type) {
        return new Response(
          JSON.stringify({ error: 'event_name, event_category et event_type sont requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Récupérer l'utilisateur si authentifié
      let userId = null
      try {
        const { data: { user } } = await supabaseClient.auth.getUser()
        userId = user?.id || null
      } catch {
        // Utilisateur non authentifié, continuer avec anonymous_id
      }

      // Vérifier le consentement analytics si utilisateur authentifié
      if (userId) {
        const { data: consent } = await supabaseClient
          .from('analytics_privacy_consents')
          .select('analytics_enabled')
          .eq('user_id', userId)
          .single()

        if (consent && !consent.analytics_enabled) {
          return new Response(
            JSON.stringify({ message: 'Analytics désactivé par l\'utilisateur' }),
            {
              status: 200,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          )
        }
      }

      const { data, error } = await supabaseClient
        .from('analytics_events')
        .insert({
          user_id: userId,
          session_id: session_id || crypto.randomUUID(),
          anonymous_id: anonymous_id || (userId ? null : crypto.randomUUID()),
          event_name,
          event_category,
          event_type,
          screen_name,
          event_properties: event_properties || {},
          app_version,
          platform,
          os_version,
          device_model,
          city,
          province,
          country: 'Canada',
        })
        .select()
        .single()

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({ data }),
        {
          status: 201,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /analytics/session - Créer ou mettre à jour une session
    if (req.method === 'POST' && endpoint === 'session') {
      const body = await req.json()
      const { session_id, action, ...sessionData } = body

      if (!session_id) {
        return new Response(
          JSON.stringify({ error: 'session_id est requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      let userId = null
      try {
        const { data: { user } } = await supabaseClient.auth.getUser()
        userId = user?.id || null
      } catch {
        // Utilisateur non authentifié
      }

      if (action === 'start') {
        const { data, error } = await supabaseClient
          .from('analytics_sessions')
          .insert({
            id: session_id,
            user_id: userId,
            anonymous_id: sessionData.anonymous_id || crypto.randomUUID(),
            started_at: new Date().toISOString(),
            is_active: true,
            entry_screen: sessionData.entry_screen,
            app_version: sessionData.app_version,
            platform: sessionData.platform,
            os_version: sessionData.os_version,
            device_model: sessionData.device_model,
            city: sessionData.city,
            province: sessionData.province,
            country: 'Canada',
          })
          .select()
          .single()

        if (error) {
          throw error
        }

        return new Response(
          JSON.stringify({ data }),
          {
            status: 201,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      } else if (action === 'end') {
        const { data: session } = await supabaseClient
          .from('analytics_sessions')
          .select('started_at')
          .eq('id', session_id)
          .single()

        if (!session) {
          return new Response(
            JSON.stringify({ error: 'Session introuvable' }),
            {
              status: 404,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          )
        }

        const duration = Math.floor(
          (new Date().getTime() - new Date(session.started_at).getTime()) / 1000
        )

        const { data, error } = await supabaseClient
          .from('analytics_sessions')
          .update({
            ended_at: new Date().toISOString(),
            duration_seconds: duration,
            is_active: false,
            exit_screen: sessionData.exit_screen,
            updated_at: new Date().toISOString(),
          })
          .eq('id', session_id)
          .select()
          .single()

        if (error) {
          throw error
        }

        return new Response(
          JSON.stringify({ data }),
          {
            status: 200,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }
    }

    // POST /analytics/conversion - Enregistrer une conversion
    if (req.method === 'POST' && endpoint === 'conversion') {
      const body = await req.json()
      const {
        conversion_type,
        conversion_value,
        listing_id,
        reservation_id,
        session_id,
        funnel_step,
        source,
        campaign,
      } = body

      if (!conversion_type) {
        return new Response(
          JSON.stringify({ error: 'conversion_type est requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      let userId = null
      try {
        const { data: { user } } = await supabaseClient.auth.getUser()
        userId = user?.id || null
      } catch {
        // Utilisateur non authentifié
      }

      const { data, error } = await supabaseClient
        .from('analytics_conversions')
        .insert({
          user_id: userId,
          session_id: session_id || null,
          anonymous_id: userId ? null : crypto.randomUUID(),
          conversion_type,
          conversion_value: conversion_value || 0,
          currency: 'CAD',
          listing_id: listing_id || null,
          reservation_id: reservation_id || null,
          funnel_step,
          source: source || 'organic',
          campaign,
        })
        .select()
        .single()

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({ data }),
        {
          status: 201,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /analytics/feedback - Enregistrer un feedback
    if (req.method === 'POST' && endpoint === 'feedback') {
      const body = await req.json()
      const {
        feedback_type,
        nps_score,
        csat_score,
        ces_score,
        rating,
        comment,
        screen_name,
        listing_id,
        reservation_id,
        categories,
      } = body

      if (!feedback_type) {
        return new Response(
          JSON.stringify({ error: 'feedback_type est requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      let userId = null
      try {
        const { data: { user } } = await supabaseClient.auth.getUser()
        userId = user?.id || null
      } catch {
        // Utilisateur non authentifié
      }

      const { data, error } = await supabaseClient
        .from('analytics_satisfaction')
        .insert({
          user_id: userId,
          anonymous_id: userId ? null : crypto.randomUUID(),
          feedback_type,
          nps_score,
          csat_score,
          ces_score,
          rating,
          comment,
          screen_name,
          listing_id: listing_id || null,
          reservation_id: reservation_id || null,
          categories: categories || [],
        })
        .select()
        .single()

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({ data }),
        {
          status: 201,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    return new Response(
      JSON.stringify({ error: 'Méthode non supportée' }),
      {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})


