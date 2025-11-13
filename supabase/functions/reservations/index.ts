// ============================================
// Campbnb Québec - Edge Function: Reservations API
// ============================================
// Gestion des réservations (CRUD)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ReservationRequest {
  listing_id: string
  check_in_date: string
  check_out_date: string
  number_of_guests: number
  number_of_adults: number
  number_of_children?: number
  guest_message?: string
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
    const reservationId = pathParts[pathParts.length - 1]

    // GET /reservations - Liste des réservations de l'utilisateur
    if (req.method === 'GET' && !reservationId) {
      const { searchParams } = url
      const role = searchParams.get('role') // 'guest' ou 'host'
      const status = searchParams.get('status')
      const page = parseInt(searchParams.get('page') || '1')
      const limit = parseInt(searchParams.get('limit') || '20')
      const offset = (page - 1) * limit

      let query = supabaseClient
        .from('reservations')
        .select(`
          *,
          listings:listing_id (
            id,
            title,
            cover_image_url,
            city,
            province,
            base_price_per_night
          ),
          guest:guest_id (
            id,
            first_name,
            last_name,
            avatar_url
          ),
          host:host_id (
            id,
            first_name,
            last_name,
            avatar_url
          )
        `)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (role === 'guest') {
        query = query.eq('guest_id', user.id)
      } else if (role === 'host') {
        query = query.eq('host_id', user.id)
      } else {
        // Par défaut, retourner les deux
        query = query.or(`guest_id.eq.${user.id},host_id.eq.${user.id}`)
      }

      if (status) {
        query = query.eq('status', status)
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

    // GET /reservations/:id - Récupérer une réservation spécifique
    if (req.method === 'GET' && reservationId) {
      const { data, error } = await supabaseClient
        .from('reservations')
        .select(`
          *,
          listings:listing_id (
            *,
            profiles:host_id (
              id,
              first_name,
              last_name,
              avatar_url,
              phone
            )
          ),
          guest:guest_id (
            id,
            first_name,
            last_name,
            avatar_url,
            email,
            phone
          ),
          host:host_id (
            id,
            first_name,
            last_name,
            avatar_url,
            email,
            phone
          )
        `)
        .eq('id', reservationId)
        .single()

      if (error) {
        throw error
      }

      // Vérifier que l'utilisateur a accès à cette réservation
      if (data.guest_id !== user.id && data.host_id !== user.id) {
        return new Response(
          JSON.stringify({ error: 'Non autorisé' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      return new Response(
        JSON.stringify({ data }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /reservations - Créer une nouvelle réservation
    if (req.method === 'POST') {
      const body: ReservationRequest = await req.json()

      // Vérifier la disponibilité
      const { data: isAvailable } = await supabaseClient.rpc(
        'is_listing_available',
        {
          p_listing_id: body.listing_id,
          p_check_in: body.check_in_date,
          p_check_out: body.check_out_date,
        }
      )

      if (!isAvailable) {
        return new Response(
          JSON.stringify({ error: 'Les dates sélectionnées ne sont pas disponibles' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Récupérer les informations du listing
      const { data: listing } = await supabaseClient
        .from('listings')
        .select('*')
        .eq('id', body.listing_id)
        .single()

      if (!listing) {
        return new Response(
          JSON.stringify({ error: 'Listing introuvable' }),
          {
            status: 404,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Calculer le prix total
      const { data: pricing } = await supabaseClient.rpc(
        'calculate_reservation_total',
        {
          p_listing_id: body.listing_id,
          p_check_in: body.check_in_date,
          p_check_out: body.check_out_date,
          p_number_of_guests: body.number_of_guests,
        }
      )

      if (!pricing || pricing.length === 0) {
        return new Response(
          JSON.stringify({ error: 'Erreur lors du calcul du prix' }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const priceData = pricing[0]

      // Créer la réservation
      const { data, error } = await supabaseClient
        .from('reservations')
        .insert({
          listing_id: body.listing_id,
          guest_id: user.id,
          host_id: listing.host_id,
          check_in_date: body.check_in_date,
          check_out_date: body.check_out_date,
          number_of_guests: body.number_of_guests,
          number_of_adults: body.number_of_adults,
          number_of_children: body.number_of_children || 0,
          base_price: priceData.base_price,
          cleaning_fee: priceData.cleaning_fee,
          service_fee: priceData.service_fee,
          taxes: priceData.taxes,
          total_price: priceData.total_price,
          guest_message: body.guest_message,
          status: 'pending',
        })
        .select(`
          *,
          listings:listing_id (
            id,
            title,
            cover_image_url
          )
        `)
        .single()

      if (error) {
        throw error
      }

      // Créer une notification pour l'hôte
      await supabaseClient
        .from('notifications')
        .insert({
          user_id: listing.host_id,
          type: 'reservation_request',
          title: 'Nouvelle demande de réservation',
          message: `${user.email} a demandé une réservation pour ${listing.title}`,
          data: {
            reservation_id: data.id,
            listing_id: body.listing_id,
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

    // PUT /reservations/:id - Mettre à jour une réservation
    if (req.method === 'PUT' && reservationId) {
      const body = await req.json()

      // Récupérer la réservation
      const { data: reservation } = await supabaseClient
        .from('reservations')
        .select('*')
        .eq('id', reservationId)
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

      // Vérifier les permissions
      const isGuest = reservation.guest_id === user.id
      const isHost = reservation.host_id === user.id

      if (!isGuest && !isHost) {
        return new Response(
          JSON.stringify({ error: 'Non autorisé' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const updateData: any = {}

      // L'hôte peut confirmer ou rejeter
      if (isHost && body.status) {
        if (body.status === 'confirmed') {
          updateData.status = 'confirmed'
          updateData.confirmed_at = new Date().toISOString()
        } else if (body.status === 'rejected') {
          updateData.status = 'rejected'
          updateData.cancellation_reason = body.cancellation_reason
        }
        if (body.host_message) {
          updateData.host_message = body.host_message
        }
      }

      // L'invité peut annuler
      if (isGuest && body.status === 'cancelled') {
        updateData.status = 'cancelled'
        updateData.cancelled_at = new Date().toISOString()
        updateData.cancellation_reason = body.cancellation_reason
      }

      const { data, error } = await supabaseClient
        .from('reservations')
        .update(updateData)
        .eq('id', reservationId)
        .select()
        .single()

      if (error) {
        throw error
      }

      // Créer une notification
      const notificationUserId = isHost ? reservation.guest_id : reservation.host_id
      const notificationType = updateData.status === 'confirmed' 
        ? 'reservation_confirmed' 
        : 'reservation_cancelled'

      await supabaseClient
        .from('notifications')
        .insert({
          user_id: notificationUserId,
          type: notificationType,
          title: updateData.status === 'confirmed' 
            ? 'Réservation confirmée' 
            : 'Réservation annulée',
          message: updateData.status === 'confirmed'
            ? 'Votre réservation a été confirmée'
            : 'Votre réservation a été annulée',
          data: {
            reservation_id: reservationId,
          },
        })

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


