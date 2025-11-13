-- ============================================
-- Campbnb Québec - Migration: Reservation Timeouts
-- ============================================
-- Ajoute le support pour les timeouts automatiques de réservations

-- Fonction pour vérifier et annuler les réservations expirées
CREATE OR REPLACE FUNCTION public.cancel_expired_reservations()
RETURNS TABLE(
  cancelled_count INTEGER,
  reservation_ids UUID[]
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  timeout_hours INTEGER := 24;
  timeout_date TIMESTAMPTZ;
  cancelled_ids UUID[];
BEGIN
  -- Calculer la date limite (24 heures avant maintenant)
  timeout_date := NOW() - (timeout_hours || ' hours')::INTERVAL;

  -- Mettre à jour les réservations expirées
  WITH updated AS (
    UPDATE public.reservations
    SET 
      status = 'cancelled',
      cancelled_at = NOW(),
      cancellation_reason = 'Timeout automatique: l''hôte n''a pas répondu dans les 24 heures',
      updated_at = NOW()
    WHERE 
      status = 'pending'
      AND requested_at < timeout_date
    RETURNING id, guest_id, host_id, listing_id
  )
  SELECT 
    COUNT(*)::INTEGER,
    ARRAY_AGG(id)
  INTO cancelled_count, cancelled_ids
  FROM updated;

  -- Créer des notifications pour les réservations annulées
  INSERT INTO public.notifications (user_id, type, title, message, data)
  SELECT 
    guest_id,
    'reservation_cancelled',
    'Réservation annulée automatiquement',
    'Votre demande de réservation a été annulée car l''hôte n''a pas répondu dans les 24 heures.',
    jsonb_build_object(
      'reservation_id', id,
      'listing_id', listing_id,
      'reason', 'timeout'
    )
  FROM public.reservations
  WHERE 
    status = 'cancelled'
    AND cancelled_at >= NOW() - INTERVAL '1 minute'
    AND cancellation_reason LIKE '%Timeout automatique%';

  -- Notifications pour les hôtes
  INSERT INTO public.notifications (user_id, type, title, message, data)
  SELECT 
    host_id,
    'reservation_cancelled',
    'Réservation expirée',
    'Une demande de réservation a été automatiquement annulée car vous n''avez pas répondu dans les 24 heures.',
    jsonb_build_object(
      'reservation_id', id,
      'listing_id', listing_id,
      'reason', 'timeout'
    )
  FROM public.reservations
  WHERE 
    status = 'cancelled'
    AND cancelled_at >= NOW() - INTERVAL '1 minute'
    AND cancellation_reason LIKE '%Timeout automatique%';

  RETURN QUERY SELECT cancelled_count, cancelled_ids;
END;
$$;

-- Index pour optimiser la recherche de réservations expirées
CREATE INDEX IF NOT EXISTS idx_reservations_pending_timeout 
ON public.reservations(status, requested_at) 
WHERE status = 'pending';

-- Fonction pour obtenir les réservations proches de l'expiration (pour notifications)
CREATE OR REPLACE FUNCTION public.get_reservations_near_timeout(
  hours_before_timeout INTEGER DEFAULT 2
)
RETURNS TABLE(
  reservation_id UUID,
  guest_id UUID,
  host_id UUID,
  listing_id UUID,
  hours_remaining NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  timeout_hours INTEGER := 24;
  warning_date TIMESTAMPTZ;
BEGIN
  warning_date := NOW() - ((timeout_hours - hours_before_timeout) || ' hours')::INTERVAL;

  RETURN QUERY
  SELECT 
    r.id,
    r.guest_id,
    r.host_id,
    r.listing_id,
    EXTRACT(EPOCH FROM (r.requested_at + (timeout_hours || ' hours')::INTERVAL - NOW())) / 3600.0 AS hours_remaining
  FROM public.reservations r
  WHERE 
    r.status = 'pending'
    AND r.requested_at >= warning_date
    AND r.requested_at < (NOW() - ((timeout_hours - hours_before_timeout - 1) || ' hours')::INTERVAL)
  ORDER BY r.requested_at ASC;
END;
$$;

-- Commentaires
COMMENT ON FUNCTION public.cancel_expired_reservations() IS 
'Annule automatiquement les réservations pending qui ont dépassé le timeout de 24 heures';

COMMENT ON FUNCTION public.get_reservations_near_timeout(INTEGER) IS 
'Retourne les réservations qui approchent du timeout pour envoyer des notifications de rappel';

