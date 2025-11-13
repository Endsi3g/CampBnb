-- ============================================
-- Campbnb Québec - Schéma Analytics
-- ============================================
-- Tables pour collecter, analyser et visualiser les données d'utilisation
-- Respecte la privacy et l'anonymisation des données

-- ============================================
-- TABLE: analytics_events (Événements utilisateur)
-- ============================================
CREATE TABLE public.analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- Identification anonymisée
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    session_id UUID NOT NULL,
    anonymous_id TEXT, -- ID anonyme pour privacy
    
    -- Événement
    event_name TEXT NOT NULL,
    event_category TEXT NOT NULL, -- 'navigation', 'interaction', 'conversion', 'error', 'performance'
    event_type TEXT NOT NULL, -- 'screen_view', 'button_click', 'search', 'reservation', etc.
    
    -- Contexte
    screen_name TEXT,
    screen_class TEXT,
    previous_screen TEXT,
    
    -- Données de l'événement (JSON flexible)
    event_properties JSONB DEFAULT '{}'::jsonb,
    
    -- Métadonnées
    app_version TEXT,
    platform TEXT, -- 'ios', 'android', 'web'
    os_version TEXT,
    device_model TEXT,
    device_id TEXT, -- Hashé pour privacy
    
    -- Localisation (anonymisée - ville/province seulement)
    city TEXT,
    province TEXT,
    country TEXT DEFAULT 'Canada',
    
    -- Performance
    load_time_ms INTEGER,
    response_time_ms INTEGER,
    
    -- Timestamp
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index pour requêtes fréquentes
CREATE INDEX idx_analytics_events_user_id ON public.analytics_events(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_analytics_events_session_id ON public.analytics_events(session_id);
CREATE INDEX idx_analytics_events_event_name ON public.analytics_events(event_name);
CREATE INDEX idx_analytics_events_event_category ON public.analytics_events(event_category);
CREATE INDEX idx_analytics_events_created_at ON public.analytics_events(created_at DESC);
CREATE INDEX idx_analytics_events_screen_name ON public.analytics_events(screen_name);
CREATE INDEX idx_analytics_events_anonymous_id ON public.analytics_events(anonymous_id);

-- Index GIN pour recherches dans event_properties
CREATE INDEX idx_analytics_events_properties ON public.analytics_events USING GIN (event_properties);

-- ============================================
-- TABLE: analytics_sessions (Sessions utilisateur)
-- ============================================
CREATE TABLE public.analytics_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    anonymous_id TEXT NOT NULL,
    
    -- Durée et activité
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    duration_seconds INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Navigation
    entry_screen TEXT,
    exit_screen TEXT,
    screens_viewed INTEGER DEFAULT 0,
    events_count INTEGER DEFAULT 0,
    
    -- Contexte
    app_version TEXT,
    platform TEXT,
    os_version TEXT,
    device_model TEXT,
    device_id TEXT, -- Hashé
    
    -- Localisation (anonymisée)
    city TEXT,
    province TEXT,
    country TEXT DEFAULT 'Canada',
    
    -- Engagement
    interactions_count INTEGER DEFAULT 0,
    searches_count INTEGER DEFAULT 0,
    listings_viewed INTEGER DEFAULT 0,
    
    -- Conversion
    conversion_type TEXT, -- 'signup', 'reservation', 'listing_created', etc.
    conversion_value DECIMAL(10, 2),
    
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index
CREATE INDEX idx_analytics_sessions_user_id ON public.analytics_sessions(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_analytics_sessions_anonymous_id ON public.analytics_sessions(anonymous_id);
CREATE INDEX idx_analytics_sessions_started_at ON public.analytics_sessions(started_at DESC);
CREATE INDEX idx_analytics_sessions_is_active ON public.analytics_sessions(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_analytics_sessions_conversion_type ON public.analytics_sessions(conversion_type) WHERE conversion_type IS NOT NULL;

-- ============================================
-- TABLE: analytics_conversions (Conversions)
-- ============================================
CREATE TABLE public.analytics_conversions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    session_id UUID REFERENCES public.analytics_sessions(id) ON DELETE SET NULL,
    anonymous_id TEXT,
    
    -- Type de conversion
    conversion_type TEXT NOT NULL CHECK (conversion_type IN (
        'signup', 'login', 'listing_view', 'listing_favorite', 
        'reservation_request', 'reservation_confirmed', 'reservation_completed',
        'listing_created', 'review_submitted', 'message_sent', 'profile_completed'
    )),
    
    -- Valeur
    conversion_value DECIMAL(10, 2),
    currency TEXT DEFAULT 'CAD',
    
    -- Contexte
    listing_id UUID REFERENCES public.listings(id) ON DELETE SET NULL,
    reservation_id UUID REFERENCES public.reservations(id) ON DELETE SET NULL,
    
    -- Funnel
    funnel_step TEXT, -- 'awareness', 'interest', 'consideration', 'purchase', 'retention'
    funnel_position INTEGER,
    
    -- Attribution
    source TEXT, -- 'organic', 'search', 'direct', 'referral', 'social'
    campaign TEXT,
    referrer TEXT,
    
    -- Métadonnées
    event_properties JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index
CREATE INDEX idx_analytics_conversions_user_id ON public.analytics_conversions(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_analytics_conversions_session_id ON public.analytics_conversions(session_id);
CREATE INDEX idx_analytics_conversions_conversion_type ON public.analytics_conversions(conversion_type);
CREATE INDEX idx_analytics_conversions_created_at ON public.analytics_conversions(created_at DESC);
CREATE INDEX idx_analytics_conversions_listing_id ON public.analytics_conversions(listing_id) WHERE listing_id IS NOT NULL;
CREATE INDEX idx_analytics_conversions_funnel_step ON public.analytics_conversions(funnel_step);

-- ============================================
-- TABLE: analytics_satisfaction (Satisfaction utilisateur)
-- ============================================
CREATE TABLE public.analytics_satisfaction (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    anonymous_id TEXT,
    
    -- Type de feedback
    feedback_type TEXT NOT NULL CHECK (feedback_type IN (
        'nps', 'csat', 'ces', 'rating', 'review', 'bug_report', 'feature_request'
    )),
    
    -- Scores
    nps_score INTEGER CHECK (nps_score >= 0 AND nps_score <= 10),
    csat_score INTEGER CHECK (csat_score >= 1 AND csat_score <= 5),
    ces_score INTEGER CHECK (ces_score >= 1 AND ces_score <= 7),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    
    -- Commentaires
    comment TEXT,
    sentiment TEXT, -- 'positive', 'neutral', 'negative' (analysé par Gemini)
    sentiment_score DECIMAL(3, 2), -- -1.0 à 1.0
    
    -- Contexte
    screen_name TEXT,
    listing_id UUID REFERENCES public.listings(id) ON DELETE SET NULL,
    reservation_id UUID REFERENCES public.reservations(id) ON DELETE SET NULL,
    
    -- Catégories
    categories TEXT[], -- ['bug', 'ui', 'performance', 'feature']
    
    -- Métadonnées
    app_version TEXT,
    platform TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index
CREATE INDEX idx_analytics_satisfaction_user_id ON public.analytics_satisfaction(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_analytics_satisfaction_feedback_type ON public.analytics_satisfaction(feedback_type);
CREATE INDEX idx_analytics_satisfaction_created_at ON public.analytics_satisfaction(created_at DESC);
CREATE INDEX idx_analytics_satisfaction_sentiment ON public.analytics_satisfaction(sentiment);
CREATE INDEX idx_analytics_satisfaction_nps_score ON public.analytics_satisfaction(nps_score) WHERE nps_score IS NOT NULL;

-- ============================================
-- TABLE: analytics_user_behaviors (Comportements utilisateur - analysés par Gemini)
-- ============================================
CREATE TABLE public.analytics_user_behaviors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    anonymous_id TEXT NOT NULL,
    
    -- Période d'analyse
    analysis_date DATE NOT NULL,
    analysis_period TEXT NOT NULL CHECK (analysis_period IN ('daily', 'weekly', 'monthly')),
    
    -- Comportements détectés (JSON analysé par Gemini)
    behaviors JSONB NOT NULL DEFAULT '{}'::jsonb, -- {patterns: [], insights: [], recommendations: []}
    
    -- Métriques agrégées
    sessions_count INTEGER DEFAULT 0,
    total_time_minutes INTEGER DEFAULT 0,
    screens_viewed INTEGER DEFAULT 0,
    interactions_count INTEGER DEFAULT 0,
    searches_count INTEGER DEFAULT 0,
    conversions_count INTEGER DEFAULT 0,
    
    -- Préférences détectées
    preferred_property_types TEXT[],
    preferred_locations TEXT[],
    preferred_price_range JSONB, -- {min: 0, max: 1000}
    preferred_amenities TEXT[],
    
    -- Personnalisation
    personalization_score DECIMAL(3, 2), -- 0.0 à 1.0
    engagement_score DECIMAL(3, 2), -- 0.0 à 1.0
    retention_probability DECIMAL(3, 2), -- 0.0 à 1.0
    
    -- Recommandations IA
    ai_recommendations JSONB DEFAULT '[]'::jsonb,
    ai_insights TEXT,
    
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Contrainte unique : un utilisateur/anonyme par période
    CONSTRAINT unique_user_period_behavior UNIQUE (COALESCE(user_id::TEXT, anonymous_id), analysis_date, analysis_period)
);

-- Index
CREATE INDEX idx_analytics_user_behaviors_user_id ON public.analytics_user_behaviors(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_analytics_user_behaviors_anonymous_id ON public.analytics_user_behaviors(anonymous_id);
CREATE INDEX idx_analytics_user_behaviors_analysis_date ON public.analytics_user_behaviors(analysis_date DESC);
CREATE INDEX idx_analytics_user_behaviors_behaviors ON public.analytics_user_behaviors USING GIN (behaviors);
CREATE INDEX idx_analytics_user_behaviors_ai_recommendations ON public.analytics_user_behaviors USING GIN (ai_recommendations);

-- ============================================
-- TABLE: analytics_privacy_consents (Consentements privacy)
-- ============================================
CREATE TABLE public.analytics_privacy_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    anonymous_id TEXT NOT NULL,
    
    -- Consentements
    analytics_enabled BOOLEAN DEFAULT TRUE,
    personalization_enabled BOOLEAN DEFAULT TRUE,
    data_sharing_enabled BOOLEAN DEFAULT FALSE,
    
    -- Préférences
    data_retention_days INTEGER DEFAULT 365,
    anonymization_level TEXT DEFAULT 'standard' CHECK (anonymization_level IN ('minimal', 'standard', 'maximum')),
    
    -- Métadonnées
    consent_version TEXT NOT NULL, -- Version de la politique de privacy
    consent_given_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    consent_updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Contrainte unique : un consentement par utilisateur/anonyme
    CONSTRAINT unique_user_consent UNIQUE (COALESCE(user_id::TEXT, anonymous_id))
);

-- Index
CREATE INDEX idx_analytics_privacy_consents_user_id ON public.analytics_privacy_consents(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_analytics_privacy_consents_anonymous_id ON public.analytics_privacy_consents(anonymous_id);

-- ============================================
-- TRIGGERS: Mise à jour automatique de updated_at
-- ============================================
CREATE TRIGGER update_analytics_sessions_updated_at BEFORE UPDATE ON public.analytics_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_analytics_user_behaviors_updated_at BEFORE UPDATE ON public.analytics_user_behaviors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_analytics_privacy_consents_updated_at BEFORE UPDATE ON public.analytics_privacy_consents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FUNCTIONS: Fonctions utilitaires analytics
-- ============================================

-- Fonction pour anonymiser un user_id (hash)
CREATE OR REPLACE FUNCTION public.anonymize_user_id(p_user_id UUID)
RETURNS TEXT AS $$
BEGIN
    RETURN encode(digest(p_user_id::TEXT || current_setting('app.salt', TRUE), 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour calculer la durée de session
CREATE OR REPLACE FUNCTION public.calculate_session_duration(p_session_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_duration INTEGER;
BEGIN
    SELECT EXTRACT(EPOCH FROM (ended_at - started_at))::INTEGER
    INTO v_duration
    FROM public.analytics_sessions
    WHERE id = p_session_id AND ended_at IS NOT NULL;
    
    RETURN COALESCE(v_duration, 0);
END;
$$ LANGUAGE plpgsql;

-- Fonction pour mettre à jour les stats de session
CREATE OR REPLACE FUNCTION public.update_session_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Mettre à jour le compteur d'événements de la session
        UPDATE public.analytics_sessions
        SET 
            events_count = events_count + 1,
            screens_viewed = CASE 
                WHEN NEW.event_type = 'screen_view' THEN screens_viewed + 1 
                ELSE screens_viewed 
            END,
            interactions_count = CASE 
                WHEN NEW.event_category = 'interaction' THEN interactions_count + 1 
                ELSE interactions_count 
            END,
            searches_count = CASE 
                WHEN NEW.event_type = 'search' THEN searches_count + 1 
                ELSE searches_count 
            END,
            listings_viewed = CASE 
                WHEN NEW.event_type = 'listing_view' THEN listings_viewed + 1 
                ELSE listings_viewed 
            END,
            updated_at = NOW()
        WHERE id = NEW.session_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour les stats de session
CREATE TRIGGER update_session_stats_after_event
    AFTER INSERT ON public.analytics_events
    FOR EACH ROW EXECUTE FUNCTION public.update_session_stats();

-- Fonction pour nettoyer les données anonymes anciennes (respect privacy)
CREATE OR REPLACE FUNCTION public.cleanup_old_anonymous_data()
RETURNS INTEGER AS $$
DECLARE
    v_deleted_count INTEGER;
    v_retention_days INTEGER := 90; -- Par défaut 90 jours pour données anonymes
BEGIN
    -- Supprimer les événements anonymes de plus de 90 jours
    DELETE FROM public.analytics_events
    WHERE user_id IS NULL 
        AND anonymous_id IS NOT NULL
        AND created_at < NOW() - (v_retention_days || ' days')::INTERVAL;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    
    -- Supprimer les sessions anonymes terminées de plus de 90 jours
    DELETE FROM public.analytics_sessions
    WHERE user_id IS NULL 
        AND anonymous_id IS NOT NULL
        AND is_active = FALSE
        AND ended_at < NOW() - (v_retention_days || ' days')::INTERVAL;
    
    GET DIAGNOSTICS v_deleted_count = v_deleted_count + ROW_COUNT;
    
    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Activer RLS sur toutes les tables analytics
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_conversions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_satisfaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_user_behaviors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_privacy_consents ENABLE ROW LEVEL SECURITY;

-- POLICIES: analytics_events
-- Les utilisateurs peuvent insérer leurs propres événements
CREATE POLICY "Users can insert own analytics events"
    ON public.analytics_events FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Les utilisateurs peuvent lire leurs propres événements
CREATE POLICY "Users can read own analytics events"
    ON public.analytics_events FOR SELECT
    USING (auth.uid() = user_id OR user_id IS NULL);

-- POLICIES: analytics_sessions
-- Les utilisateurs peuvent insérer leurs propres sessions
CREATE POLICY "Users can insert own analytics sessions"
    ON public.analytics_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Les utilisateurs peuvent lire et mettre à jour leurs propres sessions
CREATE POLICY "Users can manage own analytics sessions"
    ON public.analytics_sessions FOR ALL
    USING (auth.uid() = user_id OR user_id IS NULL)
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- POLICIES: analytics_conversions
-- Les utilisateurs peuvent insérer leurs propres conversions
CREATE POLICY "Users can insert own analytics conversions"
    ON public.analytics_conversions FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Les utilisateurs peuvent lire leurs propres conversions
CREATE POLICY "Users can read own analytics conversions"
    ON public.analytics_conversions FOR SELECT
    USING (auth.uid() = user_id OR user_id IS NULL);

-- POLICIES: analytics_satisfaction
-- Les utilisateurs peuvent insérer leurs propres feedbacks
CREATE POLICY "Users can insert own analytics satisfaction"
    ON public.analytics_satisfaction FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Les utilisateurs peuvent lire leurs propres feedbacks
CREATE POLICY "Users can read own analytics satisfaction"
    ON public.analytics_satisfaction FOR SELECT
    USING (auth.uid() = user_id OR user_id IS NULL);

-- POLICIES: analytics_user_behaviors
-- Les utilisateurs peuvent lire leurs propres comportements
CREATE POLICY "Users can read own analytics behaviors"
    ON public.analytics_user_behaviors FOR SELECT
    USING (auth.uid() = user_id OR user_id IS NULL);

-- POLICIES: analytics_privacy_consents
-- Les utilisateurs peuvent gérer leurs propres consentements
CREATE POLICY "Users can manage own privacy consents"
    ON public.analytics_privacy_consents FOR ALL
    USING (auth.uid() = user_id OR user_id IS NULL)
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- ============================================
-- COMMENTAIRES
-- ============================================
COMMENT ON TABLE public.analytics_events IS 'Événements utilisateur pour analytics';
COMMENT ON TABLE public.analytics_sessions IS 'Sessions utilisateur pour analytics';
COMMENT ON TABLE public.analytics_conversions IS 'Conversions et objectifs business';
COMMENT ON TABLE public.analytics_satisfaction IS 'Feedback et satisfaction utilisateur';
COMMENT ON TABLE public.analytics_user_behaviors IS 'Comportements utilisateur analysés par IA';
COMMENT ON TABLE public.analytics_privacy_consents IS 'Consentements privacy et préférences utilisateur';



