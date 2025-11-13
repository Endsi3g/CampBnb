#!/bin/bash
# Script bash pour créer le fichier .env
# Usage: ./scripts/create_env.sh

ENV_CONTENT="# ============================================
# Campbnb Québec - Variables d'environnement
# ============================================

# Supabase Configuration
# Project URL: https://kniaisdkzeflauawmyka.supabase.co
SUPABASE_URL=https://kniaisdkzeflauawmyka.supabase.co

# Anon Key (utilisez SUPABASE_KEY ou SUPABASE_ANON_KEY)
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuaWFpc2RremVmbGF1YXdteWthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNDk2NzMsImV4cCI6MjA3ODYyNTY3M30.HL5ZhIZS7abfeuHnPW54KN8qQgsoXohfYwJhO0Tgyoo

# MapBox (déjà configuré avec valeur par défaut dans le code)
MAPBOX_ACCESS_TOKEN=pk.eyJ1IjoiY2FtcGJuYiIsImEiOiJjbWh3N21wZjAwNDhuMm9weXFwMmt1c2VqIn0.r6bKsNWgKmIb0FzWOcZh8g

# Google Gemini (optionnel)
GEMINI_API_KEY=your-gemini-api-key-here

# Stripe (optionnel - pour les paiements)
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key_here

# Sentry (optionnel - pour le monitoring d'erreurs)
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id"

ENV_PATH="$(dirname "$0")/../.env"

if [ -f "$ENV_PATH" ]; then
    echo "⚠️  Le fichier .env existe déjà."
    read -p "Voulez-vous le remplacer? (o/N): " overwrite
    if [ "$overwrite" != "o" ] && [ "$overwrite" != "O" ]; then
        echo "❌ Opération annulée."
        exit 0
    fi
fi

echo "$ENV_CONTENT" > "$ENV_PATH"
echo "✅ Fichier .env créé avec succès !"
echo "📍 Emplacement: $ENV_PATH"

