# Script PowerShell pour créer le fichier .env
# Usage: .\scripts\create_env.ps1

$envContent = @"
# ============================================
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
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
"@

$envPath = Join-Path $PSScriptRoot ".." ".env"

if (Test-Path $envPath) {
    Write-Host "⚠️  Le fichier .env existe déjà." -ForegroundColor Yellow
    $overwrite = Read-Host "Voulez-vous le remplacer? (o/N)"
    if ($overwrite -ne "o" -and $overwrite -ne "O") {
        Write-Host "❌ Opération annulée." -ForegroundColor Red
        exit
    }
}

try {
    $envContent | Out-File -FilePath $envPath -Encoding UTF8 -NoNewline
    Write-Host "✅ Fichier .env créé avec succès !" -ForegroundColor Green
    Write-Host "📍 Emplacement: $envPath" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erreur lors de la création du fichier .env: $_" -ForegroundColor Red
    exit 1
}

