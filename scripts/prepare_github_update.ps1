# Script PowerShell pour préparer la mise à jour GitHub
# Usage: .\scripts\prepare_github_update.ps1

Write-Host "🚀 Préparation de la mise à jour GitHub" -ForegroundColor Cyan
Write-Host ""

# Vérifier l'état Git
Write-Host "📊 Vérification de l'état Git..." -ForegroundColor Yellow
$status = git status --short
if ($status) {
    Write-Host "✅ Fichiers modifiés détectés:" -ForegroundColor Green
    Write-Host $status
} else {
    Write-Host "⚠️  Aucun fichier modifié détecté" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📝 Derniers commits:" -ForegroundColor Yellow
git log --oneline -5

Write-Host ""
Write-Host "🔍 Vérification des fichiers importants..." -ForegroundColor Yellow

# Vérifier les fichiers clés
$filesToCheck = @(
    "ANALYSE_PROJET_COMPLETE_2024.md",
    "docs/CHANGELOG.md",
    "docs/TIMEOUTS_ET_CACHE.md",
    "docs/VERIFICATION_CACHE.md",
    "lib/core/cache/cache_service.dart",
    "lib/core/services/reservation_timeout_service.dart",
    "supabase/functions/reservation-timeouts/index.ts",
    "supabase/migrations/006_reservation_timeouts.sql",
    "supabase/migrations/007_search_optimization.sql"
)

$allExist = $true
foreach ($file in $filesToCheck) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file (manquant)" -ForegroundColor Red
        $allExist = $false
    }
}

Write-Host ""
if ($allExist) {
    Write-Host "✅ Tous les fichiers importants sont présents" -ForegroundColor Green
} else {
    Write-Host "⚠️  Certains fichiers sont manquants" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Commandes suggérées:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Ajouter tous les fichiers:" -ForegroundColor Yellow
Write-Host "   git add ." -ForegroundColor White
Write-Host ""
Write-Host "2. Vérifier les fichiers ajoutés:" -ForegroundColor Yellow
Write-Host "   git status" -ForegroundColor White
Write-Host ""
Write-Host "3. Commit avec message:" -ForegroundColor Yellow
Write-Host "   git commit -m `"feat: Ajout timeouts automatiques, cache persistant et optimisations recherche`"" -ForegroundColor White
Write-Host ""
Write-Host "4. Push vers GitHub:" -ForegroundColor Yellow
Write-Host "   git push origin main" -ForegroundColor White
Write-Host ""

# Proposer d'exécuter les commandes
$response = Read-Host "Voulez-vous exécuter ces commandes maintenant? (O/N)"
if ($response -eq "O" -or $response -eq "o") {
    Write-Host ""
    Write-Host "📦 Ajout des fichiers..." -ForegroundColor Yellow
    git add .
    
    Write-Host ""
    Write-Host "📝 Création du commit..." -ForegroundColor Yellow
    $commitMessage = @"
feat: Ajout timeouts automatiques, cache persistant et optimisations recherche

✨ Nouvelles fonctionnalités:
- Timeouts automatiques pour réservations (annulation après 24h)
- Cache persistant avec Hive (support offline)
- Optimisation recherche full-text PostgreSQL
- Interface de debug dans les paramètres

🔧 Améliorations:
- Performance recherche 10x plus rapide
- Support offline partiel
- Gestion automatique réservations expirées

📚 Documentation:
- Guide timeouts et cache
- Guide vérification cache
- Analyse complète projet 2024

🧪 Tests:
- 11 tests unitaires cache
- Validateur de cache
- Scripts de test
"@
    
    git commit -m $commitMessage
    
    Write-Host ""
    Write-Host "🚀 Push vers GitHub..." -ForegroundColor Yellow
    $branch = git branch --show-current
    Write-Host "Branche actuelle: $branch" -ForegroundColor Cyan
    
    $pushResponse = Read-Host "Pousser vers GitHub? (O/N)"
    if ($pushResponse -eq "O" -or $pushResponse -eq "o") {
        git push origin $branch
        Write-Host ""
        Write-Host "✅ Mise à jour GitHub terminée!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "ℹ️  Commit créé localement. Push manuel requis." -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "ℹ️  Commandes préparées. Exécution manuelle requise." -ForegroundColor Cyan
}

Write-Host ""

