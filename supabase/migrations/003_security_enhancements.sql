-- ============================================
-- Campbnb Québec - Améliorations de Sécurité
-- ============================================
-- Migration 003 : Authentification forte, chiffrement, rôles/permissions

-- ============================================
-- TABLE: user_security_settings (Paramètres de sécurité utilisateur)
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_security_settings (
    id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    -- Authentification multi-facteurs
    mfa_enabled BOOLEAN DEFAULT FALSE,
    mfa_method TEXT CHECK (mfa_method IN ('totp', 'sms', 'email')),
    mfa_secret TEXT, -- Chiffré avec pgcrypto
    backup_codes TEXT[], -- Chiffrés
    -- Sessions
    max_concurrent_sessions INTEGER DEFAULT 5,
    session_timeout_minutes INTEGER DEFAULT 30,
    -- Sécurité
    require_password_change BOOLEAN DEFAULT FALSE,
    password_changed_at TIMESTAMPTZ,
    last_password_change TIMESTAMPTZ,
    failed_login_attempts INTEGER DEFAULT 0,
    account_locked_until TIMESTAMPTZ,
    -- Consentement RGPD
    gdpr_consent_given BOOLEAN DEFAULT FALSE,
    gdpr_consent_date TIMESTAMPTZ,
    marketing_consent BOOLEAN DEFAULT FALSE,
    analytics_consent BOOLEAN DEFAULT TRUE,
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index
CREATE INDEX idx_user_security_settings_mfa ON public.user_security_settings(mfa_enabled);
CREATE INDEX idx_user_security_settings_locked ON public.user_security_settings(account_locked_until) WHERE account_locked_until > NOW();

-- ============================================
-- TABLE: user_roles (Rôles et permissions)
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('guest', 'host', 'moderator', 'admin')),
    granted_by UUID REFERENCES public.profiles(id),
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT unique_user_role UNIQUE (user_id, role)
);

-- Index
CREATE INDEX idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX idx_user_roles_role ON public.user_roles(role);
CREATE INDEX idx_user_roles_active ON public.user_roles(is_active) WHERE is_active = TRUE;

-- ============================================
-- TABLE: user_permissions (Permissions granulaires)
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    permission TEXT NOT NULL,
    resource_type TEXT,
    resource_id UUID,
    granted_by UUID REFERENCES public.profiles(id),
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE
);

-- Index
CREATE INDEX idx_user_permissions_user_id ON public.user_permissions(user_id);
CREATE INDEX idx_user_permissions_permission ON public.user_permissions(permission);
CREATE INDEX idx_user_permissions_resource ON public.user_permissions(resource_type, resource_id);

-- ============================================
-- TABLE: security_audit_log (Journal d'audit de sécurité)
-- ============================================
CREATE TABLE IF NOT EXISTS public.security_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL CHECK (event_type IN (
        'login_success', 'login_failed', 'logout',
        'mfa_enabled', 'mfa_disabled', 'mfa_verified',
        'password_changed', 'password_reset_requested',
        'permission_granted', 'permission_revoked',
        'role_changed', 'account_locked', 'account_unlocked',
        'data_exported', 'data_deleted', 'consent_updated',
        'suspicious_activity', 'security_alert'
    )),
    event_details JSONB DEFAULT '{}'::jsonb,
    ip_address INET,
    user_agent TEXT,
    severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')) DEFAULT 'low',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index pour recherches rapides
CREATE INDEX idx_security_audit_log_user_id ON public.security_audit_log(user_id);
CREATE INDEX idx_security_audit_log_event_type ON public.security_audit_log(event_type);
CREATE INDEX idx_security_audit_log_created_at ON public.security_audit_log(created_at DESC);
CREATE INDEX idx_security_audit_log_severity ON public.security_audit_log(severity);
CREATE INDEX idx_security_audit_log_user_event ON public.security_audit_log(user_id, event_type, created_at DESC);

-- ============================================
-- TABLE: encrypted_data (Données chiffrées sensibles)
-- ============================================
CREATE TABLE IF NOT EXISTS public.encrypted_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    data_type TEXT NOT NULL CHECK (data_type IN ('phone', 'address', 'payment_info', 'document', 'other')),
    encrypted_value BYTEA NOT NULL, -- Chiffré avec pgcrypto
    encryption_key_id TEXT, -- Référence à la clé de chiffrement
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index
CREATE INDEX idx_encrypted_data_user_id ON public.encrypted_data(user_id);
CREATE INDEX idx_encrypted_data_type ON public.encrypted_data(data_type);

-- ============================================
-- TABLE: gdpr_consents (Consentements RGPD)
-- ============================================
CREATE TABLE IF NOT EXISTS public.gdpr_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    consent_type TEXT NOT NULL CHECK (consent_type IN (
        'data_processing', 'marketing', 'analytics', 'cookies', 'third_party'
    )),
    consent_given BOOLEAN NOT NULL,
    consent_date TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    consent_version TEXT, -- Version de la politique de confidentialité
    ip_address INET,
    user_agent TEXT,
    revoked_at TIMESTAMPTZ,
    CONSTRAINT unique_user_consent_type UNIQUE (user_id, consent_type, consent_date)
);

-- Index
CREATE INDEX idx_gdpr_consents_user_id ON public.gdpr_consents(user_id);
CREATE INDEX idx_gdpr_consents_type ON public.gdpr_consents(consent_type);
CREATE INDEX idx_gdpr_consents_active ON public.gdpr_consents(user_id, consent_type) WHERE revoked_at IS NULL;

-- ============================================
-- TABLE: security_incidents (Incidents de sécurité)
-- ============================================
CREATE TABLE IF NOT EXISTS public.security_incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_type TEXT NOT NULL CHECK (incident_type IN (
        'data_breach', 'unauthorized_access', 'ddos', 'malware', 'phishing',
        'vulnerability', 'misconfiguration', 'other'
    )),
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    status TEXT NOT NULL CHECK (status IN ('detected', 'contained', 'resolved', 'closed')) DEFAULT 'detected',
    description TEXT NOT NULL,
    affected_users INTEGER DEFAULT 0,
    detected_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    contained_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    reported_to_authorities BOOLEAN DEFAULT FALSE,
    reported_at TIMESTAMPTZ,
    remediation_notes TEXT,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index
CREATE INDEX idx_security_incidents_severity ON public.security_incidents(severity);
CREATE INDEX idx_security_incidents_status ON public.security_incidents(status);
CREATE INDEX idx_security_incidents_detected_at ON public.security_incidents(detected_at DESC);

-- ============================================
-- ROW LEVEL SECURITY pour les nouvelles tables
-- ============================================

-- user_security_settings
ALTER TABLE public.user_security_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own security settings"
    ON public.user_security_settings FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own security settings"
    ON public.user_security_settings FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own roles"
    ON public.user_roles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all roles"
    ON public.user_roles FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin' AND is_active = TRUE
        )
    );

-- user_permissions
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own permissions"
    ON public.user_permissions FOR SELECT
    USING (auth.uid() = user_id);

-- security_audit_log (lecture limitée)
ALTER TABLE public.security_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own audit logs"
    ON public.security_audit_log FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all audit logs"
    ON public.security_audit_log FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin' AND is_active = TRUE
        )
    );

-- encrypted_data
ALTER TABLE public.encrypted_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own encrypted data"
    ON public.encrypted_data FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own encrypted data"
    ON public.encrypted_data FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- gdpr_consents
ALTER TABLE public.gdpr_consents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own consents"
    ON public.gdpr_consents FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own consents"
    ON public.gdpr_consents FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own consents"
    ON public.gdpr_consents FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- security_incidents (admin uniquement)
ALTER TABLE public.security_incidents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage security incidents"
    ON public.security_incidents FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin' AND is_active = TRUE
        )
    );

-- ============================================
-- FUNCTIONS: Fonctions de sécurité
-- ============================================

-- Fonction pour chiffrer des données sensibles
CREATE OR REPLACE FUNCTION encrypt_sensitive_data(
    p_data TEXT,
    p_key TEXT DEFAULT 'campbnb_encryption_key'
)
RETURNS BYTEA AS $$
BEGIN
    RETURN pgp_sym_encrypt(p_data, p_key);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour déchiffrer des données sensibles
CREATE OR REPLACE FUNCTION decrypt_sensitive_data(
    p_encrypted_data BYTEA,
    p_key TEXT DEFAULT 'campbnb_encryption_key'
)
RETURNS TEXT AS $$
BEGIN
    RETURN pgp_sym_decrypt(p_encrypted_data, p_key);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour vérifier les permissions
CREATE OR REPLACE FUNCTION has_permission(
    p_user_id UUID,
    p_permission TEXT,
    p_resource_type TEXT DEFAULT NULL,
    p_resource_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_has_role_permission BOOLEAN;
    v_has_explicit_permission BOOLEAN;
BEGIN
    -- Vérifier les permissions via les rôles
    SELECT EXISTS (
        SELECT 1 FROM public.user_roles ur
        WHERE ur.user_id = p_user_id
        AND ur.is_active = TRUE
        AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
        AND (
            (ur.role = 'admin') OR
            (ur.role = 'moderator' AND p_permission LIKE 'moderate:%') OR
            (ur.role = 'host' AND p_permission LIKE 'host:%') OR
            (ur.role = 'guest' AND p_permission LIKE 'guest:%')
        )
    ) INTO v_has_role_permission;

    IF v_has_role_permission THEN
        RETURN TRUE;
    END IF;

    -- Vérifier les permissions explicites
    SELECT EXISTS (
        SELECT 1 FROM public.user_permissions up
        WHERE up.user_id = p_user_id
        AND up.permission = p_permission
        AND up.is_active = TRUE
        AND (up.expires_at IS NULL OR up.expires_at > NOW())
        AND (p_resource_type IS NULL OR up.resource_type = p_resource_type)
        AND (p_resource_id IS NULL OR up.resource_id = p_resource_id)
    ) INTO v_has_explicit_permission;

    RETURN v_has_explicit_permission;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour logger les événements de sécurité
CREATE OR REPLACE FUNCTION log_security_event(
    p_user_id UUID,
    p_event_type TEXT,
    p_event_details JSONB DEFAULT '{}'::jsonb,
    p_severity TEXT DEFAULT 'low',
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_log_id UUID;
BEGIN
    INSERT INTO public.security_audit_log (
        user_id, event_type, event_details, severity, ip_address, user_agent
    ) VALUES (
        p_user_id, p_event_type, p_event_details, p_severity, p_ip_address, p_user_agent
    ) RETURNING id INTO v_log_id;

    RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour vérifier et verrouiller le compte après tentatives échouées
CREATE OR REPLACE FUNCTION check_and_lock_account(
    p_user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_failed_attempts INTEGER;
    v_locked_until TIMESTAMPTZ;
BEGIN
    SELECT failed_login_attempts, account_locked_until
    INTO v_failed_attempts, v_locked_until
    FROM public.user_security_settings
    WHERE id = p_user_id;

    -- Si le compte est déjà verrouillé, vérifier si le délai est expiré
    IF v_locked_until IS NOT NULL AND v_locked_until > NOW() THEN
        RETURN TRUE; -- Compte verrouillé
    END IF;

    -- Si 5 tentatives échouées, verrouiller pour 30 minutes
    IF v_failed_attempts >= 5 THEN
        UPDATE public.user_security_settings
        SET account_locked_until = NOW() + INTERVAL '30 minutes',
            failed_login_attempts = 0
        WHERE id = p_user_id;

        -- Logger l'événement
        PERFORM log_security_event(
            p_user_id,
            'account_locked',
            jsonb_build_object('reason', 'too_many_failed_attempts', 'attempts', v_failed_attempts),
            'high'
        );

        RETURN TRUE; -- Compte verrouillé
    END IF;

    RETURN FALSE; -- Compte non verrouillé
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour réinitialiser les tentatives de connexion après succès
CREATE OR REPLACE FUNCTION reset_failed_login_attempts(
    p_user_id UUID
)
RETURNS void AS $$
BEGIN
    UPDATE public.user_security_settings
    SET failed_login_attempts = 0,
        account_locked_until = NULL
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour incrémenter les tentatives de connexion échouées
CREATE OR REPLACE FUNCTION increment_failed_login_attempts(
    p_user_id UUID
)
RETURNS void AS $$
BEGIN
    UPDATE public.user_security_settings
    SET failed_login_attempts = COALESCE(failed_login_attempts, 0) + 1
    WHERE id = p_user_id;

    -- Créer l'enregistrement s'il n'existe pas
    IF NOT FOUND THEN
        INSERT INTO public.user_security_settings (id, failed_login_attempts)
        VALUES (p_user_id, 1)
        ON CONFLICT (id) DO UPDATE
        SET failed_login_attempts = user_security_settings.failed_login_attempts + 1;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGERS: Création automatique des paramètres de sécurité
-- ============================================

-- Créer automatiquement les paramètres de sécurité lors de la création d'un profil
CREATE OR REPLACE FUNCTION create_user_security_settings()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_security_settings (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;

    -- Attribuer le rôle 'guest' par défaut
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'guest')
    ON CONFLICT (user_id, role) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_profile_created_security
    AFTER INSERT ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION create_user_security_settings();

-- ============================================
-- TRIGGERS: Mise à jour automatique de updated_at
-- ============================================

CREATE TRIGGER update_user_security_settings_updated_at
    BEFORE UPDATE ON public.user_security_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_encrypted_data_updated_at
    BEFORE UPDATE ON public.encrypted_data
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_security_incidents_updated_at
    BEFORE UPDATE ON public.security_incidents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- COMMENTAIRES
-- ============================================
COMMENT ON TABLE public.user_security_settings IS 'Paramètres de sécurité et authentification multi-facteurs';
COMMENT ON TABLE public.user_roles IS 'Rôles et permissions des utilisateurs';
COMMENT ON TABLE public.user_permissions IS 'Permissions granulaires des utilisateurs';
COMMENT ON TABLE public.security_audit_log IS 'Journal d''audit de sécurité';
COMMENT ON TABLE public.encrypted_data IS 'Données sensibles chiffrées';
COMMENT ON TABLE public.gdpr_consents IS 'Consentements RGPD des utilisateurs';
COMMENT ON TABLE public.security_incidents IS 'Incidents de sécurité et leur gestion';
