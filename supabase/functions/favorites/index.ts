// ============================================
// Campbnb Québec - Edge Function: Favorites API
// ============================================
// Gestion des favoris

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
    const listingId = pathParts[pathParts.length - 1]

    // GET /favorites - Liste des favoris de l'utilisateur
    if (req.method === 'GET' && !listingId) {
      const { data, error } = await supabaseClient
        .from('favorites')
        .select(`
          *,
          listings:listing_id (
            id,
            title,
            cover_image_url,
            base_price_per_night,
            city,
            province,
            average_rating,
            total_reviews
          )
        `)
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

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

    // POST /favorites/:listing_id - Ajouter un favori
    if (req.method === 'POST' && listingId) {
      // Vérifier que le listing existe
      const { data: listing } = await supabaseClient
        .from('listings')
        .select('id')
        .eq('id', listingId)
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

      const { data, error } = await supabaseClient
        .from('favorites')
        .insert({
          user_id: user.id,
          listing_id: listingId,
        })
        .select()
        .single()

      if (error) {
        // Si l'erreur est due à une contrainte unique, le favori existe déjà
        if (error.code === '23505') {
          return new Response(
            JSON.stringify({ message: 'Déjà en favoris', data: null }),
            {
              status: 200,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          )
        }
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

    // DELETE /favorites/:listing_id - Supprimer un favori
    if (req.method === 'DELETE' && listingId) {
      const { error } = await supabaseClient
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('listing_id', listingId)

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({ message: 'Favori supprimé' }),
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


