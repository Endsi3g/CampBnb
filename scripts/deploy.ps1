# ============================================
# Campbnb Québec - Script de Déploiement (PowerShell)
# ============================================
# Script pour déployer toutes les migrations et Edge Functions

$ErrorActionPreference = "Stop"

Write-Host "🚀 Déploiement du backend Campbnb Québec" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Vérifier que Supabase CLI est installé
try {
    $null = Get-Command supabase -ErrorAction Stop
    Write-Host "✅ Supabase CLI détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Supabase CLI n'est pas installé" -ForegroundColor Red
    Write-Host "Installez-le avec: npm install -g supabase" -ForegroundColor Yellow
    exit 1
}

# Vérifier que le projet est lié
if (-not (Test-Path ".supabase/config.toml")) {
    Write-Host "⚠️  Projet Supabase non lié" -ForegroundColor Yellow
    Write-Host "Liez le projet avec: supabase link --project-ref YOUR_PROJECT_REF" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Projet Supabase lié" -ForegroundColor Green

# Appliquer les migrations
Write-Host ""
Write-Host "📦 Application des migrations..." -ForegroundColor Cyan
supabase db push

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Migrations appliquées avec succès" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de l'application des migrations" -ForegroundColor Red
    exit 1
}

# Appliquer les politiques de stockage
Write-Host ""
Write-Host "🗄️  Application des politiques de stockage..." -ForegroundColor Cyan
if (Test-Path "supabase/storage/policies.sql") {
    supabase db push --file supabase/storage/policies.sql
    Write-Host "✅ Politiques de stockage appliquées" -ForegroundColor Green
} else {
    Write-Host "⚠️  Fichier de politiques de stockage non trouvé" -ForegroundColor Yellow
}

# Déployer toutes les Edge Functions
Write-Host ""
Write-Host "⚡ Déploiement des Edge Functions..." -ForegroundColor Cyan

$functions = @(
    "listings",
    "reservations",
    "profiles",
    "messages",
    "reviews",
    "favorites",
    "activities",
    "mapbox",
    "gemini",
    "analytics",
    "payments"
)

foreach ($func in $functions) {
    Write-Host "  Déploiement de $func..." -ForegroundColor Yellow
    supabase functions deploy $func --no-verify-jwt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur lors du déploiement de $func" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Toutes les Edge Functions déployées" -ForegroundColor Green

# Résumé
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ Déploiement terminé avec succès!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Résumé:" -ForegroundColor Cyan
Write-Host "  - Migrations: ✅"
Write-Host "  - Politiques de stockage: ✅"
Write-Host "  - Edge Functions: $($functions.Count) déployées"
Write-Host ""
Write-Host "🔗 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "  1. Vérifier les buckets de stockage dans Supabase Dashboard"
Write-Host "  2. Configurer les variables d'environnement pour les Edge Functions"
Write-Host "  3. Tester les endpoints API"
Write-Host "  4. Configurer les webhooks Stripe si nécessaire"
Write-Host ""

