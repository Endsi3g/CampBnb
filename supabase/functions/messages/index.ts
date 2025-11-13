// ============================================
// Campbnb Québec - Edge Function: Messages API
// ============================================
// Gestion des messages entre utilisateurs

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
    const conversationId = pathParts[pathParts.length - 1]

    // GET /messages/conversations - Liste des conversations
    if (req.method === 'GET' && url.pathname.includes('/conversations')) {
      // Récupérer toutes les conversations où l'utilisateur est impliqué
      const { data: messages, error } = await supabaseClient
        .from('messages')
        .select(`
          *,
          sender:sender_id (
            id,
            first_name,
            last_name,
            avatar_url
          ),
          recipient:recipient_id (
            id,
            first_name,
            last_name,
            avatar_url
          )
        `)
        .or(`sender_id.eq.${user.id},recipient_id.eq.${user.id}`)
        .order('created_at', { ascending: false })

      if (error) {
        throw error
      }

      // Grouper par conversation_id
      const conversations = new Map()
      for (const message of messages || []) {
        const otherUserId = message.sender_id === user.id 
          ? message.recipient_id 
          : message.sender_id
        
        if (!conversations.has(message.conversation_id)) {
          conversations.set(message.conversation_id, {
            conversation_id: message.conversation_id,
            other_user: message.sender_id === user.id ? message.recipient : message.sender,
            last_message: message,
            unread_count: 0,
          })
        }

        const conv = conversations.get(message.conversation_id)
        if (!message.is_read && message.recipient_id === user.id) {
          conv.unread_count++
        }
      }

      return new Response(
        JSON.stringify({ 
          data: Array.from(conversations.values()) 
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // GET /messages/:conversation_id - Récupérer les messages d'une conversation
    if (req.method === 'GET' && conversationId) {
      const { searchParams } = url
      const page = parseInt(searchParams.get('page') || '1')
      const limit = parseInt(searchParams.get('limit') || '50')
      const offset = (page - 1) * limit

      const { data, error } = await supabaseClient
        .from('messages')
        .select(`
          *,
          sender:sender_id (
            id,
            first_name,
            last_name,
            avatar_url
          ),
          recipient:recipient_id (
            id,
            first_name,
            last_name,
            avatar_url
          )
        `)
        .eq('conversation_id', conversationId)
        .or(`sender_id.eq.${user.id},recipient_id.eq.${user.id}`)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (error) {
        throw error
      }

      // Marquer les messages comme lus
      await supabaseClient
        .from('messages')
        .update({ 
          is_read: true,
          read_at: new Date().toISOString(),
        })
        .eq('conversation_id', conversationId)
        .eq('recipient_id', user.id)
        .eq('is_read', false)

      return new Response(
        JSON.stringify({ 
          data: data?.reverse() || [],
          pagination: {
            page,
            limit,
          },
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // POST /messages - Envoyer un message
    if (req.method === 'POST') {
      const body = await req.json()
      const { recipient_id, content, reservation_id } = body

      if (!recipient_id || !content) {
        return new Response(
          JSON.stringify({ error: 'recipient_id et content sont requis' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // Générer ou récupérer le conversation_id
      // Utiliser le plus petit ID suivi du plus grand pour garantir l'unicité
      const userIds = [user.id, recipient_id].sort()
      const conversationId = `${userIds[0]}_${userIds[1]}`

      const { data, error } = await supabaseClient
        .from('messages')
        .insert({
          conversation_id,
          sender_id: user.id,
          recipient_id,
          content,
          reservation_id: reservation_id || null,
          is_read: false,
        })
        .select(`
          *,
          sender:sender_id (
            id,
            first_name,
            last_name,
            avatar_url
          ),
          recipient:recipient_id (
            id,
            first_name,
            last_name,
            avatar_url
          )
        `)
        .single()

      if (error) {
        throw error
      }

      // Créer une notification pour le destinataire
      await supabaseClient
        .from('notifications')
        .insert({
          user_id: recipient_id,
          type: 'message',
          title: 'Nouveau message',
          message: `Vous avez reçu un message de ${user.email}`,
          data: {
            conversation_id,
            message_id: data.id,
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


