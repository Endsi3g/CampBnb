// ============================================
// Campbnb Québec - Edge Function: Gemini API
// ============================================
// Intégration avec Google Gemini 2.5 pour suggestions intelligentes

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface GeminiRequest {
  prompt: string
  context?: {
    user_id?: string
    listing_id?: string
    reservation_id?: string
    search_history?: string[]
  }
  type?: 'suggestion' | 'description' | 'recommendation' | 'chat'
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

    // L'authentification est optionnelle pour certaines requêtes publiques
    const isAuthenticated = !userError && user

    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const endpoint = pathParts[pathParts.length - 1]

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      return new Response(
        JSON.stringify({ error: 'Gemini API n\'est pas configuré' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /gemini/suggest - Générer des suggestions intelligentes
    if (req.method === 'POST' && endpoint === 'suggest') {
      const body: GeminiRequest = await req.json()
      const { prompt, context, type = 'suggestion' } = body

      if (!prompt) {
        return new Response(
          JSON.stringify({ error: 'prompt est requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Construire le contexte enrichi
      let enrichedPrompt = prompt

      if (context?.user_id && isAuthenticated) {
        // Récupérer l'historique de l'utilisateur
        const { data: userProfile } = await supabaseClient
          .from('profiles')
          .select('first_name, last_name, city, province')
          .eq('id', context.user_id)
          .single()

        if (userProfile) {
          enrichedPrompt = `Utilisateur: ${userProfile.first_name} ${userProfile.last_name}, localisé à ${userProfile.city}, ${userProfile.province}. ${enrichedPrompt}`
        }
      }

      if (context?.listing_id) {
        // Récupérer les informations du listing
        const { data: listing } = await supabaseClient
          .from('listings')
          .select('title, description, city, province, property_type, amenities')
          .eq('id', context.listing_id)
          .single()

        if (listing) {
          enrichedPrompt = `Listing: ${listing.title} à ${listing.city}, ${listing.province}. Type: ${listing.property_type}. ${enrichedPrompt}`
        }
      }

      // Préparer le prompt selon le type
      let systemPrompt = ''
      switch (type) {
        case 'suggestion':
          systemPrompt = 'Tu es un assistant expert en camping et tourisme au Québec. Fournis des suggestions pertinentes et personnalisées.'
          break
        case 'description':
          systemPrompt = 'Tu es un rédacteur expert en descriptions d\'hébergements de camping. Crée des descriptions attrayantes et précises.'
          break
        case 'recommendation':
          systemPrompt = 'Tu es un conseiller en camping au Québec. Recommande des campings basés sur les préférences de l\'utilisateur.'
          break
        case 'chat':
          systemPrompt = 'Tu es un assistant conversationnel pour Campbnb Québec. Réponds de manière amicale et utile.'
          break
      }

      const fullPrompt = `${systemPrompt}\n\n${enrichedPrompt}`

      // Appel à l'API Gemini
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${geminiApiKey}`
      
      const geminiResponse = await fetch(geminiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [{
            parts: [{
              text: fullPrompt,
            }],
          }],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          },
        }),
      })

      if (!geminiResponse.ok) {
        const errorData = await geminiResponse.json()
        throw new Error(errorData.error?.message || 'Erreur API Gemini')
      }

      const geminiData = await geminiResponse.json()
      const responseText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || ''

      // Enregistrer la requête dans l'historique (optionnel)
      if (isAuthenticated && context?.user_id) {
        // Vous pourriez créer une table pour stocker l'historique des suggestions
        // await supabaseClient.from('ai_suggestions_history').insert({ ... })
      }

      return new Response(
        JSON.stringify({
          data: {
            suggestion: responseText,
            type,
            timestamp: new Date().toISOString(),
          },
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /gemini/describe-listing - Générer une description pour un listing
    if (req.method === 'POST' && endpoint === 'describe-listing') {
      if (!isAuthenticated) {
        return new Response(
          JSON.stringify({ error: 'Authentification requise' }),
          {
            status: 401,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const body = await req.json()
      const { listing_id } = body

      if (!listing_id) {
        return new Response(
          JSON.stringify({ error: 'listing_id est requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Vérifier que l'utilisateur est le propriétaire
      const { data: listing } = await supabaseClient
        .from('listings')
        .select('*')
        .eq('id', listing_id)
        .eq('host_id', user.id)
        .single()

      if (!listing) {
        return new Response(
          JSON.stringify({ error: 'Listing introuvable ou non autorisé' }),
          {
            status: 404,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const prompt = `Génère une description attrayante et détaillée pour ce camping au Québec:
- Titre: ${listing.title}
- Type: ${listing.property_type}
- Localisation: ${listing.city}, ${listing.province}
- Capacité: ${listing.max_guests} invités
- Équipements: ${JSON.stringify(listing.amenities)}
- Description actuelle: ${listing.description}

Crée une description de 150-200 mots qui met en valeur les points forts du camping, l'ambiance naturelle, et les activités possibles.`

      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${geminiApiKey}`
      
      const geminiResponse = await fetch(geminiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [{
            parts: [{
              text: prompt,
            }],
          }],
          generationConfig: {
            temperature: 0.8,
            maxOutputTokens: 500,
          },
        }),
      })

      if (!geminiResponse.ok) {
        const errorData = await geminiResponse.json()
        throw new Error(errorData.error?.message || 'Erreur API Gemini')
      }

      const geminiData = await geminiResponse.json()
      const description = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || ''

      return new Response(
        JSON.stringify({
          data: {
            description,
            listing_id,
          },
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /gemini/recommend - Recommandations personnalisées
    if (req.method === 'POST' && endpoint === 'recommend') {
      if (!isAuthenticated) {
        return new Response(
          JSON.stringify({ error: 'Authentification requise' }),
          {
            status: 401,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      const body = await req.json()
      const { preferences, budget, dates, location } = body

      // Récupérer l'historique de l'utilisateur
      const { data: userReservations } = await supabaseClient
        .from('reservations')
        .select(`
          listings:listing_id (
            city,
            province,
            property_type,
            amenities
          )
        `)
        .eq('guest_id', user.id)
        .in('status', ['completed', 'confirmed'])
        .limit(10)

      const prompt = `Recommandez des campings au Québec pour cet utilisateur:
- Préférences: ${JSON.stringify(preferences || {})}
- Budget: ${budget || 'Non spécifié'}
- Dates: ${dates || 'Non spécifiées'}
- Localisation souhaitée: ${location || 'Non spécifiée'}
- Historique: ${JSON.stringify(userReservations || [])}

Fournis 5 recommandations avec des explications courtes pour chaque.`

      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${geminiApiKey}`
      
      const geminiResponse = await fetch(geminiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [{
            parts: [{
              text: prompt,
            }],
          }],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 1024,
          },
        }),
      })

      if (!geminiResponse.ok) {
        const errorData = await geminiResponse.json()
        throw new Error(errorData.error?.message || 'Erreur API Gemini')
      }

      const geminiData = await geminiResponse.json()
      const recommendations = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || ''

      return new Response(
        JSON.stringify({
          data: {
            recommendations,
            timestamp: new Date().toISOString(),
          },
        }),
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


