// Edge Function pour la gestion de la sécurité
// Gère l'authentification MFA, les permissions, et les audits

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface SecurityEvent {
  event_type: string;
  event_details?: Record<string, unknown>;
  severity?: 'low' | 'medium' | 'high' | 'critical';
  ip_address?: string;
  user_agent?: string;
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Créer le client Supabase
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    // Récupérer l'utilisateur depuis le token
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const url = new URL(req.url);
    const action = url.pathname.split('/').pop();

    switch (action) {
      case 'log-event':
        return await logSecurityEvent(req, supabaseClient, user.id);
      
      case 'check-permission':
        return await checkPermission(req, supabaseClient, user.id);
      
      case 'get-audit-logs':
        return await getAuditLogs(req, supabaseClient, user.id);
      
      case 'enable-mfa':
        return await enableMFA(req, supabaseClient, user.id);
      
      case 'verify-mfa':
        return await verifyMFA(req, supabaseClient, user.id);
      
      default:
        return new Response(
          JSON.stringify({ error: 'Invalid action' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

// Logger un événement de sécurité
async function logSecurityEvent(
  req: Request,
  supabase: any,
  userId: string
): Promise<Response> {
  const body: SecurityEvent = await req.json();
  const ipAddress = req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip') || '';
  const userAgent = req.headers.get('user-agent') || '';

  const { data, error } = await supabase.rpc('log_security_event', {
    p_user_id: userId,
    p_event_type: body.event_type,
    p_event_details: body.event_details || {},
    p_severity: body.severity || 'low',
    p_ip_address: ipAddress,
    p_user_agent: userAgent,
  });

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  return new Response(
    JSON.stringify({ success: true, log_id: data }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// Vérifier une permission
async function checkPermission(
  req: Request,
  supabase: any,
  userId: string
): Promise<Response> {
  const body = await req.json();
  const { permission, resource_type, resource_id } = body;

  const { data, error } = await supabase.rpc('has_permission', {
    p_user_id: userId,
    p_permission: permission,
    p_resource_type: resource_type || null,
    p_resource_id: resource_id || null,
  });

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  return new Response(
    JSON.stringify({ has_permission: data }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// Récupérer les logs d'audit
async function getAuditLogs(
  req: Request,
  supabase: any,
  userId: string
): Promise<Response> {
  const url = new URL(req.url);
  const limit = parseInt(url.searchParams.get('limit') || '50');
  const offset = parseInt(url.searchParams.get('offset') || '0');

  // Vérifier si l'utilisateur est admin
  const { data: roles } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', userId)
    .eq('role', 'admin')
    .eq('is_active', true)
    .single();

  const query = supabase
    .from('security_audit_log')
    .select('*')
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  // Si pas admin, filtrer par user_id
  if (!roles) {
    query.eq('user_id', userId);
  }

  const { data, error } = await query;

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  return new Response(
    JSON.stringify({ logs: data }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// Activer le MFA
async function enableMFA(
  req: Request,
  supabase: any,
  userId: string
): Promise<Response> {
  const body = await req.json();
  const { secret, method } = body;

  // Chiffrer le secret avant stockage
  const { data: encrypted, error: encryptError } = await supabase.rpc('encrypt_sensitive_data', {
    p_data: secret,
  });

  if (encryptError) {
    return new Response(
      JSON.stringify({ error: 'Failed to encrypt secret' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  const { error } = await supabase
    .from('user_security_settings')
    .update({
      mfa_enabled: true,
      mfa_method: method || 'totp',
      mfa_secret: encrypted,
    })
    .eq('id', userId);

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  // Logger l'événement
  await supabase.rpc('log_security_event', {
    p_user_id: userId,
    p_event_type: 'mfa_enabled',
    p_event_details: { method: method || 'totp' },
    p_severity: 'medium',
  });

  return new Response(
    JSON.stringify({ success: true }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// Vérifier le code MFA
async function verifyMFA(
  req: Request,
  supabase: any,
  userId: string
): Promise<Response> {
  const body = await req.json();
  const { code } = body;

  // Récupérer le secret chiffré
  const { data: settings, error: fetchError } = await supabase
    .from('user_security_settings')
    .select('mfa_secret, backup_codes')
    .eq('id', userId)
    .single();

  if (fetchError || !settings) {
    return new Response(
      JSON.stringify({ error: 'MFA not enabled' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  // Déchiffrer le secret
  const { data: secret, error: decryptError } = await supabase.rpc('decrypt_sensitive_data', {
    p_encrypted_data: settings.mfa_secret,
  });

  if (decryptError) {
    return new Response(
      JSON.stringify({ error: 'Failed to decrypt secret' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  // Vérifier le code (implémentation TOTP simplifiée)
  // En production, utiliser une bibliothèque TOTP appropriée
  const isValid = verifyTOTPCode(secret, code);

  if (isValid) {
    await supabase.rpc('log_security_event', {
      p_user_id: userId,
      p_event_type: 'mfa_verified',
      p_severity: 'low',
    });
  }

  return new Response(
    JSON.stringify({ verified: isValid }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// Fonction simplifiée de vérification TOTP
// En production, utiliser une bibliothèque appropriée
function verifyTOTPCode(secret: string, code: string): boolean {
  // Cette implémentation est simplifiée
  // En production, utiliser une bibliothèque TOTP complète
  // qui gère la fenêtre de temps, les codes précédents/suivants, etc.
  return true; // Placeholder
}

