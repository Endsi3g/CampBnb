// ============================================
// Campbnb Québec - Edge Function: Reviews API
// ============================================
// Gestion des avis et évaluations

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
    const reviewId = pathParts[pathParts.length - 1]

    // GET /reviews - Liste des reviews (filtrées par listing_id ou user_id)
    if (req.method === 'GET' && !reviewId) {
      const { searchParams } = url
      const listing_id = searchParams.get('listing_id')
      const user_id = searchParams.get('user_id')
      const page = parseInt(searchParams.get('page') || '1')
      const limit = parseInt(searchParams.get('limit') || '20')
      const offset = (page - 1) * limit

      let query = supabaseClient
        .from('reviews')
        .select(`
          *,
          reviewer:reviewer_id (
            id,
            first_name,
            last_name,
            avatar_url
          ),
          reviewee:reviewee_id (
            id,
            first_name,
            last_name,
            avatar_url
          ),
          listings:listing_id (
            id,
            title,
            cover_image_url
          )
        `)
        .eq('is_public', true)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (listing_id) {
        query = query.eq('listing_id', listing_id)
      }
      if (user_id) {
        query = query.eq('reviewee_id', user_id)
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

    // POST /reviews - Créer un avis
    if (req.method === 'POST') {
      const body = await req.json()
      const {
        reservation_id,
        review_type,
        rating_overall,
        rating_cleanliness,
        rating_communication,
        rating_check_in,
        rating_accuracy,
        rating_location,
        rating_value,
        comment,
      } = body

      // Vérifier que la réservation existe et appartient à l'utilisateur
      const { data: reservation } = await supabaseClient
        .from('reservations')
        .select('*')
        .eq('id', reservation_id)
        .single()

      if (!reservation) {
        return new Response(
          JSON.stringify({ error: 'Réservation introuvable' }),
          {
            status: 404,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      if (reservation.status !== 'completed') {
        return new Response(
          JSON.stringify({ error: 'Vous ne pouvez laisser un avis que pour une réservation terminée' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Déterminer reviewer_id et reviewee_id
      let reviewerId = user.id
      let revieweeId

      if (review_type === 'guest') {
        // L'invité évalue l'hôte
        if (reservation.guest_id !== user.id) {
          return new Response(
            JSON.stringify({ error: 'Vous ne pouvez évaluer que vos propres réservations' }),
            {
              status: 403,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          )
        }
        revieweeId = reservation.host_id
      } else if (review_type === 'host') {
        // L'hôte évalue l'invité
        if (reservation.host_id !== user.id) {
          return new Response(
            JSON.stringify({ error: 'Vous ne pouvez évaluer que vos propres réservations' }),
            {
              status: 403,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          )
        }
        revieweeId = reservation.guest_id
      } else {
        return new Response(
          JSON.stringify({ error: 'review_type doit être "guest" ou "host"' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const { data, error } = await supabaseClient
        .from('reviews')
        .insert({
          reservation_id,
          listing_id: reservation.listing_id,
          reviewer_id: reviewerId,
          reviewee_id: revieweeId,
          review_type,
          rating_overall,
          rating_cleanliness,
          rating_communication,
          rating_check_in,
          rating_accuracy,
          rating_location,
          rating_value,
          comment,
          is_public: true,
        })
        .select()
        .single()

      if (error) {
        throw error
      }

      // Créer une notification
      await supabaseClient
        .from('notifications')
        .insert({
          user_id: revieweeId,
          type: 'review',
          title: 'Nouvel avis reçu',
          message: `Vous avez reçu un nouvel avis de ${review_type === 'guest' ? 'votre invité' : 'votre hôte'}`,
          data: {
            review_id: data.id,
            reservation_id,
          },
        })

      return new Response(
        JSON.stringify({ data }),
        {
          status: 201,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // PUT /reviews/:id - Mettre à jour un avis (réponse de l'hôte)
    if (req.method === 'PUT' && reviewId) {
      const body = await req.json()

      // Récupérer la review
      const { data: review } = await supabaseClient
        .from('reviews')
        .select('*')
        .eq('id', reviewId)
        .single()

      if (!review) {
        return new Response(
          JSON.stringify({ error: 'Avis introuvable' }),
          {
            status: 404,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const updateData: any = {}

      // L'hôte peut répondre aux reviews d'invités
      if (review.review_type === 'guest' && review.reviewee_id === user.id && body.host_response) {
        updateData.host_response = body.host_response
        updateData.host_response_at = new Date().toISOString()
      } else if (review.reviewer_id === user.id) {
        // Le reviewer peut mettre à jour son propre avis
        if (body.comment !== undefined) updateData.comment = body.comment
        if (body.rating_overall !== undefined) updateData.rating_overall = body.rating_overall
        if (body.rating_cleanliness !== undefined) updateData.rating_cleanliness = body.rating_cleanliness
        if (body.rating_communication !== undefined) updateData.rating_communication = body.rating_communication
        if (body.rating_check_in !== undefined) updateData.rating_check_in = body.rating_check_in
        if (body.rating_accuracy !== undefined) updateData.rating_accuracy = body.rating_accuracy
        if (body.rating_location !== undefined) updateData.rating_location = body.rating_location
        if (body.rating_value !== undefined) updateData.rating_value = body.rating_value
      } else {
        return new Response(
          JSON.stringify({ error: 'Non autorisé' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const { data, error } = await supabaseClient
        .from('reviews')
        .update(updateData)
        .eq('id', reviewId)
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


