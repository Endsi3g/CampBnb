-- ============================================
-- Campbnb Québec - Migration: Optimisation Recherche
-- ============================================
-- Améliore les performances de recherche avec full-text search et index optimisés

-- Extension pour full-text search (si pas déjà activée)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Index GIN pour recherche textuelle rapide sur title et description
CREATE INDEX IF NOT EXISTS idx_listings_title_gin 
ON public.listings USING gin(to_tsvector('french', title));

CREATE INDEX IF NOT EXISTS idx_listings_description_gin 
ON public.listings USING gin(to_tsvector('french', description));

-- Index trigram pour recherche partielle (recherche "fuzzy")
CREATE INDEX IF NOT EXISTS idx_listings_title_trgm 
ON public.listings USING gin(title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_listings_city_trgm 
ON public.listings USING gin(city gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_listings_description_trgm 
ON public.listings USING gin(description gin_trgm_ops);

-- Index composite pour recherches fréquentes (status + city + province)
CREATE INDEX IF NOT EXISTS idx_listings_status_city_province 
ON public.listings(status, city, province) 
WHERE status = 'active' AND is_available = true;

-- Index composite pour recherche par prix et type
CREATE INDEX IF NOT EXISTS idx_listings_price_type 
ON public.listings(property_type, base_price_per_night) 
WHERE status = 'active' AND is_available = true;

-- Index pour recherche géographique (nécessite PostGIS)
-- Décommenter si PostGIS est disponible
-- CREATE INDEX IF NOT EXISTS idx_listings_location_gist 
-- ON public.listings USING GIST (
--   ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
-- );

-- Fonction pour recherche full-text optimisée
CREATE OR REPLACE FUNCTION public.search_listings_fulltext(
  search_query TEXT,
  p_city TEXT DEFAULT NULL,
  p_province TEXT DEFAULT NULL,
  p_property_type TEXT DEFAULT NULL,
  p_min_price DECIMAL DEFAULT NULL,
  p_max_price DECIMAL DEFAULT NULL,
  p_min_guests INTEGER DEFAULT NULL,
  p_page INTEGER DEFAULT 1,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE(
  id UUID,
  title TEXT,
  description TEXT,
  property_type TEXT,
  city TEXT,
  province TEXT,
  base_price_per_night DECIMAL,
  max_guests INTEGER,
  average_rating DECIMAL,
  cover_image_url TEXT,
  relevance_score REAL
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  offset_val INTEGER;
BEGIN
  offset_val := (p_page - 1) * p_limit;

  RETURN QUERY
  SELECT 
    l.id,
    l.title,
    l.description,
    l.property_type,
    l.city,
    l.province,
    l.base_price_per_night,
    l.max_guests,
    l.average_rating,
    l.cover_image_url,
    -- Score de pertinence basé sur la recherche full-text
    ts_rank(
      to_tsvector('french', coalesce(l.title, '') || ' ' || coalesce(l.description, '')),
      plainto_tsquery('french', search_query)
    ) AS relevance_score
  FROM public.listings l
  WHERE 
    l.status = 'active'
    AND l.is_available = true
    AND (
      -- Recherche full-text
      to_tsvector('french', coalesce(l.title, '') || ' ' || coalesce(l.description, '')) 
      @@ plainto_tsquery('french', search_query)
      OR
      -- Recherche partielle (fallback)
      l.title ILIKE '%' || search_query || '%'
      OR l.description ILIKE '%' || search_query || '%'
      OR l.city ILIKE '%' || search_query || '%'
    )
    AND (p_city IS NULL OR l.city ILIKE '%' || p_city || '%')
    AND (p_province IS NULL OR l.province = p_province)
    AND (p_property_type IS NULL OR l.property_type = p_property_type)
    AND (p_min_price IS NULL OR l.base_price_per_night >= p_min_price)
    AND (p_max_price IS NULL OR l.base_price_per_night <= p_max_price)
    AND (p_min_guests IS NULL OR l.max_guests >= p_min_guests)
  ORDER BY 
    relevance_score DESC,
    l.average_rating DESC NULLS LAST,
    l.created_at DESC
  LIMIT p_limit
  OFFSET offset_val;
END;
$$;

-- Fonction pour recherche géographique optimisée (si PostGIS disponible)
-- Décommenter si PostGIS est disponible
/*
CREATE OR REPLACE FUNCTION public.search_listings_nearby(
  p_latitude DECIMAL,
  p_longitude DECIMAL,
  p_radius_km INTEGER DEFAULT 50,
  p_property_type TEXT DEFAULT NULL,
  p_min_price DECIMAL DEFAULT NULL,
  p_max_price DECIMAL DEFAULT NULL,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE(
  id UUID,
  title TEXT,
  city TEXT,
  province TEXT,
  latitude DECIMAL,
  longitude DECIMAL,
  base_price_per_night DECIMAL,
  distance_km DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.title,
    l.city,
    l.province,
    l.latitude,
    l.longitude,
    l.base_price_per_night,
    ST_Distance(
      ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
      ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
    ) / 1000.0 AS distance_km
  FROM public.listings l
  WHERE 
    l.status = 'active'
    AND l.is_available = true
    AND ST_DWithin(
      ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
      ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
      p_radius_km * 1000
    )
    AND (p_property_type IS NULL OR l.property_type = p_property_type)
    AND (p_min_price IS NULL OR l.base_price_per_night >= p_min_price)
    AND (p_max_price IS NULL OR l.base_price_per_night <= p_max_price)
  ORDER BY distance_km ASC
  LIMIT p_limit;
END;
$$;
*/

-- Index pour optimiser les recherches par amenities (JSONB)
CREATE INDEX IF NOT EXISTS idx_listings_amenities_gin 
ON public.listings USING gin(amenities);

-- Fonction pour recherche par amenities
CREATE OR REPLACE FUNCTION public.search_listings_by_amenities(
  p_amenities TEXT[],
  p_city TEXT DEFAULT NULL,
  p_province TEXT DEFAULT NULL,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE(
  id UUID,
  title TEXT,
  city TEXT,
  province TEXT,
  amenities JSONB,
  base_price_per_night DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.title,
    l.city,
    l.province,
    l.amenities,
    l.base_price_per_night
  FROM public.listings l
  WHERE 
    l.status = 'active'
    AND l.is_available = true
    AND l.amenities ?| p_amenities  -- Contient au moins un des amenities
    AND (p_city IS NULL OR l.city ILIKE '%' || p_city || '%')
    AND (p_province IS NULL OR l.province = p_province)
  ORDER BY 
    l.average_rating DESC NULLS LAST,
    l.base_price_per_night ASC
  LIMIT p_limit;
END;
$$;

-- Index pour optimiser les recherches par dates (disponibilité)
CREATE INDEX IF NOT EXISTS idx_listings_dates_availability 
ON public.listings(id, status, is_available) 
WHERE status = 'active' AND is_available = true;

-- Commentaires
COMMENT ON FUNCTION public.search_listings_fulltext IS 
'Recherche full-text optimisée avec score de pertinence et filtres multiples';

COMMENT ON FUNCTION public.search_listings_by_amenities IS 
'Recherche de listings par amenities avec support JSONB';

-- Statistiques pour optimiser les requêtes
ANALYZE public.listings;

