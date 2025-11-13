# Script PowerShell pour tester manuellement la capture d'erreurs Sentry
# Utilise l'application Flutter directement

Write-Host "🧪 Test de capture d'erreurs Sentry" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Flutter est disponible
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterPath) {
    Write-Host "❌ Flutter n'est pas dans le PATH" -ForegroundColor Red
    Write-Host "Voir docs/POWERSHELL_FLUTTER_SETUP.md pour la configuration" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Flutter trouvé: $($flutterPath.Source)" -ForegroundColor Green
Write-Host ""

# Vérifier que SENTRY_DSN est configuré
$sentryDsn = $env:SENTRY_DSN
if (-not $sentryDsn) {
    Write-Host "⚠️  SENTRY_DSN non configuré" -ForegroundColor Yellow
    Write-Host "Définir avec: `$env:SENTRY_DSN = 'https://your-dsn@sentry.io/project-id'" -ForegroundColor Yellow
    Write-Host ""
}

# Options de test
Write-Host "Options de test:" -ForegroundColor Cyan
Write-Host "1. Exécuter les tests unitaires"
Write-Host "2. Lancer l'application en mode debug"
Write-Host "3. Vérifier la configuration Sentry"
Write-Host ""

$choice = Read-Host "Choisir une option (1-3)"

switch ($choice) {
    "1" {
        Write-Host "🧪 Exécution des tests unitaires..." -ForegroundColor Cyan
        flutter test test/monitoring/error_capture_test.dart
    }
    "2" {
        Write-Host "🚀 Lancement de l'application..." -ForegroundColor Cyan
        Write-Host "Les erreurs seront capturées automatiquement" -ForegroundColor Yellow
        flutter run
    }
    "3" {
        Write-Host "🔍 Vérification de la configuration..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "SENTRY_DSN: $sentryDsn" -ForegroundColor $(if ($sentryDsn) { "Green" } else { "Red" })
        Write-Host ""
        Write-Host "Pour configurer:" -ForegroundColor Yellow
        Write-Host "1. Créer un compte sur https://sentry.io" -ForegroundColor White
        Write-Host "2. Créer un projet Flutter" -ForegroundColor White
        Write-Host "3. Récupérer le DSN" -ForegroundColor White
        Write-Host "4. Définir: `$env:SENTRY_DSN = 'your-dsn'" -ForegroundColor White
    }
    default {
        Write-Host "❌ Option invalide" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 Vérifier les erreurs dans Sentry:" -ForegroundColor Cyan
Write-Host "https://sentry.io/organizations/your-org/issues/" -ForegroundColor Blue

