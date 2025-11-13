// ============================================
// Campbnb Québec - Edge Function: Activities API
// ============================================
// Gestion des activités proposées par les hôtes

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

    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Non authentifié' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const activityId = pathParts[pathParts.length - 1]

    // GET /activities - Liste des activités
    if (req.method === 'GET' && !activityId) {
      const { searchParams } = url
      const listing_id = searchParams.get('listing_id')
      const host_id = searchParams.get('host_id')
      const activity_type = searchParams.get('activity_type')
      const status = searchParams.get('status') || 'published'
      const page = parseInt(searchParams.get('page') || '1')
      const limit = parseInt(searchParams.get('limit') || '20')
      const offset = (page - 1) * limit

      let query = supabaseClient
        .from('activities')
        .select(`
          *,
          listings:listing_id (
            id,
            title,
            city,
            province
          ),
          profiles:host_id (
            id,
            first_name,
            last_name,
            avatar_url
          )
        `)
        .eq('status', status)
        .order('start_date', { ascending: true })
        .range(offset, offset + limit - 1)

      if (listing_id) {
        query = query.eq('listing_id', listing_id)
      }
      if (host_id) {
        query = query.eq('host_id', host_id)
      }
      if (activity_type) {
        query = query.eq('activity_type', activity_type)
      }

      const { data, error, count } = await query

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({
          data,
          pagination: {
            page,
            limit,
            total: count || 0,
            total_pages: Math.ceil((count || 0) / limit),
          },
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // GET /activities/:id - Récupérer une activité
    if (req.method === 'GET' && activityId) {
      const { data, error } = await supabaseClient
        .from('activities')
        .select(`
          *,
          listings:listing_id (
            id,
            title,
            city,
            province
          ),
          profiles:host_id (
            id,
            first_name,
            last_name,
            avatar_url,
            bio
          )
        `)
        .eq('id', activityId)
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

    // POST /activities - Créer une activité
    if (req.method === 'POST') {
      const body = await req.json()

      // Vérifier que l'utilisateur est un hôte
      const { data: profile } = await supabaseClient
        .from('profiles')
        .select('is_host')
        .eq('id', user.id)
        .single()

      if (!profile?.is_host) {
        return new Response(
          JSON.stringify({ error: 'Vous devez être un hôte pour créer une activité' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const { data, error } = await supabaseClient
        .from('activities')
        .insert({
          host_id: user.id,
          listing_id: body.listing_id || null,
          title: body.title,
          description: body.description,
          activity_type: body.activity_type,
          location_name: body.location_name,
          latitude: body.latitude,
          longitude: body.longitude,
          start_date: body.start_date,
          start_time: body.start_time,
          end_date: body.end_date,
          end_time: body.end_time,
          duration_minutes: body.duration_minutes,
          max_participants: body.max_participants,
          price_per_person: body.price_per_person || 0,
          is_free: body.is_free || false,
          image_url: body.image_url,
          status: 'draft',
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

    // PUT /activities/:id - Mettre à jour une activité
    if (req.method === 'PUT' && activityId) {
      // Vérifier que l'utilisateur est le propriétaire
      const { data: activity } = await supabaseClient
        .from('activities')
        .select('host_id')
        .eq('id', activityId)
        .single()

      if (!activity || activity.host_id !== user.id) {
        return new Response(
          JSON.stringify({ error: 'Non autorisé' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const body = await req.json()
      const updateData: any = {}

      const allowedFields = [
        'title', 'description', 'activity_type', 'location_name',
        'latitude', 'longitude', 'start_date', 'start_time',
        'end_date', 'end_time', 'duration_minutes', 'max_participants',
        'price_per_person', 'is_free', 'image_url', 'status'
      ]

      for (const field of allowedFields) {
        if (body[field] !== undefined) {
          updateData[field] = body[field]
        }
      }

      const { data, error } = await supabaseClient
        .from('activities')
        .update(updateData)
        .eq('id', activityId)
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

    // DELETE /activities/:id - Supprimer une activité
    if (req.method === 'DELETE' && activityId) {
      // Vérifier que l'utilisateur est le propriétaire
      const { data: activity } = await supabaseClient
        .from('activities')
        .select('host_id')
        .eq('id', activityId)
        .single()

      if (!activity || activity.host_id !== user.id) {
        return new Response(
          JSON.stringify({ error: 'Non autorisé' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const { error } = await supabaseClient
        .from('activities')
        .update({ status: 'cancelled' })
        .eq('id', activityId)

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({ message: 'Activité supprimée avec succès' }),
        {
          status: 200,
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


