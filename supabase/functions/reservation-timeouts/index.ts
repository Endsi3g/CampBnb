// ============================================
// Campbnb Québec - Edge Function: Reservation Timeouts
// ============================================
// Annule automatiquement les réservations 'pending' après 24 heures
// Cette fonction doit être appelée périodiquement (cron job)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Timeout en heures (24 heures par défaut)
const RESERVATION_TIMEOUT_HOURS = 24

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Utiliser le service role key pour bypasser RLS
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Calculer la date limite (24 heures avant maintenant)
    const timeoutDate = new Date()
    timeoutDate.setHours(timeoutDate.getHours() - RESERVATION_TIMEOUT_HOURS)

    // Récupérer toutes les réservations 'pending' créées il y a plus de 24h
    const { data: expiredReservations, error: fetchError } = await supabaseAdmin
      .from('reservations')
      .select('id, guest_id, host_id, listing_id, total_price, requested_at')
      .eq('status', 'pending')
      .lt('requested_at', timeoutDate.toISOString())

    if (fetchError) {
      throw fetchError
    }

    if (!expiredReservations || expiredReservations.length === 0) {
      return new Response(
        JSON.stringify({ 
          message: 'Aucune réservation expirée',
          processed: 0 
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    const processedReservations: string[] = []
    const errors: Array<{ reservationId: string; error: string }> = []

    // Traiter chaque réservation expirée
    for (const reservation of expiredReservations) {
      try {
        // Mettre à jour le statut à 'cancelled'
        const { error: updateError } = await supabaseAdmin
          .from('reservations')
          .update({
            status: 'cancelled',
            cancelled_at: new Date().toISOString(),
            cancellation_reason: 'Timeout automatique: l\'hôte n\'a pas répondu dans les 24 heures',
          })
          .eq('id', reservation.id)

        if (updateError) {
          errors.push({
            reservationId: reservation.id,
            error: updateError.message,
          })
          continue
        }

        // Libérer les dates bloquées (supprimer de blocked_dates si applicable)
        // Note: Les blocked_dates sont généralement gérés par une fonction séparée
        // mais on peut les nettoyer ici si nécessaire

        // Créer une notification pour l'invité
        await supabaseAdmin
          .from('notifications')
          .insert({
            user_id: reservation.guest_id,
            type: 'reservation_cancelled',
            title: 'Réservation annulée automatiquement',
            message: 'Votre demande de réservation a été annulée car l\'hôte n\'a pas répondu dans les 24 heures.',
            data: {
              reservation_id: reservation.id,
              listing_id: reservation.listing_id,
              reason: 'timeout',
            },
          })

        // Créer une notification pour l'hôte
        await supabaseAdmin
          .from('notifications')
          .insert({
            user_id: reservation.host_id,
            type: 'reservation_cancelled',
            title: 'Réservation expirée',
            message: 'Une demande de réservation a été automatiquement annulée car vous n\'avez pas répondu dans les 24 heures.',
            data: {
              reservation_id: reservation.id,
              listing_id: reservation.listing_id,
              reason: 'timeout',
            },
          })

        processedReservations.push(reservation.id)
      } catch (error) {
        errors.push({
          reservationId: reservation.id,
          error: error instanceof Error ? error.message : 'Erreur inconnue',
        })
      }
    }

    return new Response(
      JSON.stringify({
        message: 'Traitement terminé',
        processed: processedReservations.length,
        total: expiredReservations.length,
        reservationIds: processedReservations,
        errors: errors.length > 0 ? errors : undefined,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: 'Erreur lors du traitement des timeouts',
        message: error instanceof Error ? error.message : 'Erreur inconnue',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})

