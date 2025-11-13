// ============================================
// Campbnb Québec - Edge Function: Profiles API
// ============================================
// Gestion des profils utilisateurs

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
    const profileId = pathParts[pathParts.length - 1] || user.id

    // GET /profiles/:id - Récupérer un profil
    if (req.method === 'GET') {
      const { data, error } = await supabaseClient
        .from('profiles')
        .select('*')
        .eq('id', profileId)
        .single()

      if (error) {
        throw error
      }

      // Masquer certaines informations si ce n'est pas le propre profil de l'utilisateur
      if (profileId !== user.id) {
        delete data.email
        delete data.phone
        delete data.address_line1
        delete data.address_line2
        delete data.postal_code
        delete data.notification_preferences
      }

      return new Response(
        JSON.stringify({ data }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // PUT /profiles/:id - Mettre à jour un profil
    if (req.method === 'PUT') {
      if (profileId !== user.id) {
        return new Response(
          JSON.stringify({ error: 'Vous ne pouvez modifier que votre propre profil' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const body = await req.json()
      const updateData: any = {}

      // Champs autorisés pour la mise à jour
      const allowedFields = [
        'first_name',
        'last_name',
        'phone',
        'bio',
        'date_of_birth',
        'address_line1',
        'address_line2',
        'city',
        'province',
        'postal_code',
        'country',
        'preferred_language',
        'notification_preferences',
        'avatar_url',
      ]

      for (const field of allowedFields) {
        if (body[field] !== undefined) {
          updateData[field] = body[field]
        }
      }

      // Mise à jour du statut hôte (nécessite une vérification séparée)
      if (body.is_host !== undefined && body.is_host === true) {
        // Ici, vous pourriez ajouter une logique de vérification
        updateData.is_host = true
      }

      const { data, error } = await supabaseClient
        .from('profiles')
        .update(updateData)
        .eq('id', user.id)
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

    // GET /profiles/:id/stats - Statistiques d'un profil
    if (req.method === 'GET' && url.pathname.includes('/stats')) {
      const { data: profile } = await supabaseClient
        .from('profiles')
        .select('is_host')
        .eq('id', profileId)
        .single()

      const stats: any = {}

      if (profile?.is_host) {
        // Statistiques hôte
        const { count: listingsCount } = await supabaseClient
          .from('listings')
          .select('*', { count: 'exact', head: true })
          .eq('host_id', profileId)
          .eq('status', 'active')

        const { count: reservationsCount } = await supabaseClient
          .from('reservations')
          .select('*', { count: 'exact', head: true })
          .eq('host_id', profileId)
          .in('status', ['confirmed', 'completed'])

        stats.listings_count = listingsCount || 0
        stats.reservations_count = reservationsCount || 0
      }

      // Statistiques invité
      const { count: guestReservationsCount } = await supabaseClient
        .from('reservations')
        .select('*', { count: 'exact', head: true })
        .eq('guest_id', profileId)
        .in('status', ['confirmed', 'completed'])

      const { count: reviewsCount } = await supabaseClient
        .from('reviews')
        .select('*', { count: 'exact', head: true })
        .eq('reviewee_id', profileId)
        .eq('is_public', true)

      stats.guest_reservations_count = guestReservationsCount || 0
      stats.reviews_count = reviewsCount || 0

      return new Response(
        JSON.stringify({ data: stats }),
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


