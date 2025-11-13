// ============================================
// Campbnb Québec - Edge Function: Listings API
// ============================================
// Gestion des annonces (CRUD)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ListingRequest {
  title: string
  description: string
  property_type: string
  latitude: number
  longitude: number
  address_line1: string
  address_line2?: string
  city: string
  province: string
  postal_code: string
  country?: string
  max_guests: number
  bedrooms?: number
  beds?: number
  bathrooms?: number
  amenities?: string[]
  house_rules?: string
  check_in_time?: string
  check_out_time?: string
  base_price_per_night: number
  cleaning_fee?: number
  service_fee_percentage?: number
  minimum_nights?: number
  maximum_nights?: number
  cover_image_url?: string
  image_urls?: string[]
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialiser Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Vérifier l'authentification
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
    const listingId = pathParts[pathParts.length - 1]

    // GET /listings - Liste tous les listings actifs
    if (req.method === 'GET' && !listingId) {
      const { searchParams } = url
      const city = searchParams.get('city')
      const province = searchParams.get('province')
      const property_type = searchParams.get('property_type')
      const min_price = searchParams.get('min_price')
      const max_price = searchParams.get('max_price')
      const max_guests = searchParams.get('max_guests')
      const page = parseInt(searchParams.get('page') || '1')
      const limit = parseInt(searchParams.get('limit') || '20')
      const offset = (page - 1) * limit

      let query = supabaseClient
        .from('listings')
        .select(`
          *,
          profiles:host_id (
            id,
            first_name,
            last_name,
            avatar_url,
            average_rating
          )
        `)
        .eq('status', 'active')
        .eq('is_available', true)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (city) {
        query = query.ilike('city', `%${city}%`)
      }
      if (province) {
        query = query.eq('province', province)
      }
      if (property_type) {
        query = query.eq('property_type', property_type)
      }
      if (min_price) {
        query = query.gte('base_price_per_night', min_price)
      }
      if (max_price) {
        query = query.lte('base_price_per_night', max_price)
      }
      if (max_guests) {
        query = query.gte('max_guests', max_guests)
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

    // GET /listings/:id - Récupérer un listing spécifique
    if (req.method === 'GET' && listingId) {
      // Incrémenter le compteur de vues
      await supabaseClient.rpc('increment_listing_views', { listing_id: listingId })

      const { data, error } = await supabaseClient
        .from('listings')
        .select(`
          *,
          profiles:host_id (
            id,
            first_name,
            last_name,
            avatar_url,
            bio,
            average_rating,
            total_reviews
          ),
          reviews (
            id,
            rating_overall,
            comment,
            created_at,
            profiles:reviewer_id (
              id,
              first_name,
              last_name,
              avatar_url
            )
          )
        `)
        .eq('id', listingId)
        .eq('status', 'active')
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

    // POST /listings - Créer un nouveau listing
    if (req.method === 'POST') {
      const body: ListingRequest = await req.json()

      // Vérifier que l'utilisateur est un hôte
      const { data: profile } = await supabaseClient
        .from('profiles')
        .select('is_host')
        .eq('id', user.id)
        .single()

      if (!profile?.is_host) {
        return new Response(
          JSON.stringify({ error: 'Vous devez être un hôte pour créer un listing' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const { data, error } = await supabaseClient
        .from('listings')
        .insert({
          host_id: user.id,
          title: body.title,
          description: body.description,
          property_type: body.property_type,
          latitude: body.latitude,
          longitude: body.longitude,
          address_line1: body.address_line1,
          address_line2: body.address_line2,
          city: body.city,
          province: body.province,
          postal_code: body.postal_code,
          country: body.country || 'Canada',
          max_guests: body.max_guests,
          bedrooms: body.bedrooms || 0,
          beds: body.beds || 0,
          bathrooms: body.bathrooms || 0,
          amenities: body.amenities || [],
          house_rules: body.house_rules,
          check_in_time: body.check_in_time || '15:00:00',
          check_out_time: body.check_out_time || '11:00:00',
          base_price_per_night: body.base_price_per_night,
          cleaning_fee: body.cleaning_fee || 0,
          service_fee_percentage: body.service_fee_percentage || 10.00,
          minimum_nights: body.minimum_nights || 1,
          maximum_nights: body.maximum_nights,
          cover_image_url: body.cover_image_url,
          image_urls: body.image_urls || [],
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

    // PUT /listings/:id - Mettre à jour un listing
    if (req.method === 'PUT' && listingId) {
      const body: Partial<ListingRequest> = await req.json()

      // Vérifier que l'utilisateur est le propriétaire
      const { data: listing } = await supabaseClient
        .from('listings')
        .select('host_id')
        .eq('id', listingId)
        .single()

      if (!listing || listing.host_id !== user.id) {
        return new Response(
          JSON.stringify({ error: 'Non autorisé' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const updateData: any = {}
      if (body.title) updateData.title = body.title
      if (body.description) updateData.description = body.description
      if (body.property_type) updateData.property_type = body.property_type
      if (body.latitude) updateData.latitude = body.latitude
      if (body.longitude) updateData.longitude = body.longitude
      if (body.address_line1) updateData.address_line1 = body.address_line1
      if (body.address_line2 !== undefined) updateData.address_line2 = body.address_line2
      if (body.city) updateData.city = body.city
      if (body.province) updateData.province = body.province
      if (body.postal_code) updateData.postal_code = body.postal_code
      if (body.country) updateData.country = body.country
      if (body.max_guests) updateData.max_guests = body.max_guests
      if (body.bedrooms !== undefined) updateData.bedrooms = body.bedrooms
      if (body.beds !== undefined) updateData.beds = body.beds
      if (body.bathrooms !== undefined) updateData.bathrooms = body.bathrooms
      if (body.amenities) updateData.amenities = body.amenities
      if (body.house_rules !== undefined) updateData.house_rules = body.house_rules
      if (body.check_in_time) updateData.check_in_time = body.check_in_time
      if (body.check_out_time) updateData.check_out_time = body.check_out_time
      if (body.base_price_per_night) updateData.base_price_per_night = body.base_price_per_night
      if (body.cleaning_fee !== undefined) updateData.cleaning_fee = body.cleaning_fee
      if (body.service_fee_percentage !== undefined) updateData.service_fee_percentage = body.service_fee_percentage
      if (body.minimum_nights !== undefined) updateData.minimum_nights = body.minimum_nights
      if (body.maximum_nights !== undefined) updateData.maximum_nights = body.maximum_nights
      if (body.cover_image_url !== undefined) updateData.cover_image_url = body.cover_image_url
      if (body.image_urls) updateData.image_urls = body.image_urls

      const { data, error } = await supabaseClient
        .from('listings')
        .update(updateData)
        .eq('id', listingId)
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

    // DELETE /listings/:id - Supprimer un listing (soft delete)
    if (req.method === 'DELETE' && listingId) {
      // Vérifier que l'utilisateur est le propriétaire
      const { data: listing } = await supabaseClient
        .from('listings')
        .select('host_id')
        .eq('id', listingId)
        .single()

      if (!listing || listing.host_id !== user.id) {
        return new Response(
          JSON.stringify({ error: 'Non autorisé' }),
          {
            status: 403,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const { error } = await supabaseClient
        .from('listings')
        .update({ status: 'deleted' })
        .eq('id', listingId)

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({ message: 'Listing supprimé avec succès' }),
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


