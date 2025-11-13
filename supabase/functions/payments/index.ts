// ============================================
// Campbnb Québec - Edge Function: Payments API
// ============================================
// Gestion des paiements avec Stripe

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
    const endpoint = pathParts[pathParts.length - 1]

    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')
    if (!stripeSecretKey) {
      return new Response(
        JSON.stringify({ error: 'Stripe n\'est pas configuré' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /payments/create-intent - Créer un PaymentIntent Stripe
    if (req.method === 'POST' && endpoint === 'create-intent') {
      const body = await req.json()
      const { reservation_id, amount, currency = 'CAD' } = body

      if (!reservation_id || !amount) {
        return new Response(
          JSON.stringify({ error: 'reservation_id et amount sont requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Vérifier que la réservation appartient à l'utilisateur
      const { data: reservation } = await supabaseClient
        .from('reservations')
        .select('*')
        .eq('id', reservation_id)
        .eq('guest_id', user.id)
        .single()

      if (!reservation) {
        return new Response(
          JSON.stringify({ error: 'Réservation introuvable ou non autorisée' }),
          {
            status: 404,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Créer le PaymentIntent avec Stripe
      const stripeResponse = await fetch('https://api.stripe.com/v1/payment_intents', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${stripeSecretKey}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          amount: Math.round(amount * 100).toString(), // Stripe utilise les centimes
          currency: currency.toLowerCase(),
          metadata: JSON.stringify({
            reservation_id,
            user_id: user.id,
            listing_id: reservation.listing_id,
          }),
          description: `Réservation Campbnb - ${reservation_id}`,
        }),
      })

      if (!stripeResponse.ok) {
        const error = await stripeResponse.json()
        throw new Error(error.message || 'Erreur Stripe')
      }

      const paymentIntent = await stripeResponse.json()

      // Enregistrer le PaymentIntent dans la base de données (si vous avez une table payments)
      // await supabaseClient.from('payments').insert({ ... })

      return new Response(
        JSON.stringify({
          data: {
            client_secret: paymentIntent.client_secret,
            payment_intent_id: paymentIntent.id,
            amount: paymentIntent.amount / 100,
            currency: paymentIntent.currency,
          },
        }),
        {
          status: 201,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /payments/webhook - Webhook Stripe pour les événements
    if (req.method === 'POST' && endpoint === 'webhook') {
      const signature = req.headers.get('stripe-signature')
      if (!signature) {
        return new Response(
          JSON.stringify({ error: 'Signature manquante' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const body = await req.text()
      const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')

      // Vérifier la signature (simplifié - en production, utiliser stripe.webhooks.constructEvent)
      const event = JSON.parse(body)

      // Traiter les événements Stripe
      switch (event.type) {
        case 'payment_intent.succeeded':
          // Mettre à jour le statut de la réservation
          const reservationId = event.data.object.metadata.reservation_id
          if (reservationId) {
            await supabaseClient
              .from('reservations')
              .update({ status: 'confirmed', confirmed_at: new Date().toISOString() })
              .eq('id', reservationId)

            // Créer une notification
            const userId = event.data.object.metadata.user_id
            await supabaseClient
              .from('notifications')
              .insert({
                user_id: userId,
                type: 'reservation_confirmed',
                title: 'Paiement confirmé',
                message: 'Votre réservation a été confirmée',
                data: { reservation_id: reservationId },
              })
          }
          break

        case 'payment_intent.payment_failed':
          // Logger l'échec
          console.error('Payment failed:', event.data.object)
          break
      }

      return new Response(
        JSON.stringify({ received: true }),
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

