// ============================================
// Campbnb Québec - Edge Function: MapBox API
// ============================================
// Gestion des cartes personnalisées avec MapBox

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface MapBoxConfig {
  accessToken: string
  styleUrl?: string
  center?: [number, number]
  zoom?: number
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

    // GET /mapbox/config - Récupérer la configuration MapBox
    if (req.method === 'GET' && pathParts[pathParts.length - 1] === 'config') {
      const mapboxToken = Deno.env.get('MAPBOX_ACCESS_TOKEN')
      
      if (!mapboxToken) {
        return new Response(
          JSON.stringify({ error: 'MapBox n\'est pas configuré' }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const config: MapBoxConfig = {
        accessToken: mapboxToken,
        styleUrl: Deno.env.get('MAPBOX_STYLE_URL') || 'mapbox://styles/mapbox/outdoors-v12',
        center: [-71.2089, 46.8139], // Centre par défaut: Québec, Canada
        zoom: 8,
      }

      return new Response(
        JSON.stringify({ data: config }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // GET /mapbox/listings - Récupérer les listings pour la carte
    if (req.method === 'GET' && pathParts[pathParts.length - 1] === 'listings') {
      const { searchParams } = url
      const bounds = searchParams.get('bounds') // Format: "minLng,minLat,maxLng,maxLat"
      const city = searchParams.get('city')
      const province = searchParams.get('province')

      let query = supabaseClient
        .from('listings')
        .select(`
          id,
          title,
          latitude,
          longitude,
          cover_image_url,
          base_price_per_night,
          property_type,
          city,
          province,
          average_rating,
          total_reviews
        `)
        .eq('status', 'active')
        .eq('is_available', true)

      if (city) {
        query = query.ilike('city', `%${city}%`)
      }
      if (province) {
        query = query.eq('province', province)
      }

      // Si des bounds sont fournies, filtrer par zone géographique
      if (bounds) {
        const [minLng, minLat, maxLng, maxLat] = bounds.split(',').map(Number)
        query = query
          .gte('longitude', minLng)
          .lte('longitude', maxLng)
          .gte('latitude', minLat)
          .lte('latitude', maxLat)
      }

      const { data, error } = await query

      if (error) {
        throw error
      }

      // Formater les données pour MapBox
      const features = (data || []).map((listing) => ({
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [listing.longitude, listing.latitude],
        },
        properties: {
          id: listing.id,
          title: listing.title,
          image: listing.cover_image_url,
          price: listing.base_price_per_night,
          type: listing.property_type,
          city: listing.city,
          province: listing.province,
          rating: listing.average_rating,
          reviews: listing.total_reviews,
        },
      }))

      return new Response(
        JSON.stringify({
          type: 'FeatureCollection',
          features,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /mapbox/geocode - Géocodage inverse (coordonnées -> adresse)
    if (req.method === 'POST' && pathParts[pathParts.length - 1] === 'geocode') {
      const body = await req.json()
      const { lng, lat } = body

      if (!lng || !lat) {
        return new Response(
          JSON.stringify({ error: 'lng et lat sont requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const mapboxToken = Deno.env.get('MAPBOX_ACCESS_TOKEN')
      if (!mapboxToken) {
        return new Response(
          JSON.stringify({ error: 'MapBox n\'est pas configuré' }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Appel à l'API MapBox Geocoding
      const geocodeUrl = `https://api.mapbox.com/geocoding/v5/mapbox.places/${lng},${lat}.json?access_token=${mapboxToken}&language=fr`
      const geocodeResponse = await fetch(geocodeUrl)
      const geocodeData = await geocodeResponse.json()

      if (!geocodeResponse.ok) {
        throw new Error(geocodeData.message || 'Erreur de géocodage')
      }

      return new Response(
        JSON.stringify({ data: geocodeData }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /mapbox/search - Recherche d'adresses (forward geocoding)
    if (req.method === 'POST' && pathParts[pathParts.length - 1] === 'search') {
      const body = await req.json()
      const { query: searchQuery, proximity } = body

      if (!searchQuery) {
        return new Response(
          JSON.stringify({ error: 'query est requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const mapboxToken = Deno.env.get('MAPBOX_ACCESS_TOKEN')
      if (!mapboxToken) {
        return new Response(
          JSON.stringify({ error: 'MapBox n\'est pas configuré' }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Appel à l'API MapBox Geocoding
      let searchUrl = `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(searchQuery)}.json?access_token=${mapboxToken}&language=fr&country=ca&limit=10`
      
      if (proximity) {
        const [lng, lat] = proximity
        searchUrl += `&proximity=${lng},${lat}`
      }

      const searchResponse = await fetch(searchUrl)
      const searchData = await searchResponse.json()

      if (!searchResponse.ok) {
        throw new Error(searchData.message || 'Erreur de recherche')
      }

      return new Response(
        JSON.stringify({ data: searchData }),
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


