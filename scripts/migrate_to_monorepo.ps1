# Script de migration vers le monorepo (PowerShell)
# Usage: .\scripts\migrate_to_monorepo.ps1

Write-Host "🚀 Migration vers le monorepo Campbnb Québec..." -ForegroundColor Green

# Vérifier que nous sommes à la racine du projet
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Erreur: Ce script doit être exécuté à la racine du projet" -ForegroundColor Red
    exit 1
}

# Créer la structure si elle n'existe pas
Write-Host "📁 Création de la structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "packages/shared/lib" | Out-Null
New-Item -ItemType Directory -Force -Path "packages/shared/assets" | Out-Null

# Déplacer le code
if (Test-Path "lib/core") {
    Write-Host "📦 Déplacement de lib/core..." -ForegroundColor Yellow
    Copy-Item -Path "lib/core" -Destination "packages/shared/lib/" -Recurse -Force
}

if (Test-Path "lib/features") {
    Write-Host "📦 Déplacement de lib/features..." -ForegroundColor Yellow
    Copy-Item -Path "lib/features" -Destination "packages/shared/lib/" -Recurse -Force
}

if (Test-Path "lib/shared") {
    Write-Host "📦 Déplacement de lib/shared..." -ForegroundColor Yellow
    Copy-Item -Path "lib/shared" -Destination "packages/shared/lib/" -Recurse -Force
}

# Déplacer les assets
if (Test-Path "assets") {
    Write-Host "🎨 Déplacement des assets..." -ForegroundColor Yellow
    Copy-Item -Path "assets" -Destination "packages/shared/" -Recurse -Force
}

# Déplacer les fichiers de configuration si nécessaire
if (Test-Path "analysis_options.yaml") {
    Write-Host "⚙️  Copie de analysis_options.yaml..." -ForegroundColor Yellow
    Copy-Item -Path "analysis_options.yaml" -Destination "packages/shared/" -Force
}

Write-Host ""
Write-Host "✅ Migration terminée!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Prochaines étapes :" -ForegroundColor Cyan
Write-Host "   1. Vérifier que le code a été correctement déplacé"
Write-Host "   2. Installer les dépendances :"
Write-Host "      cd packages/shared; flutter pub get"
Write-Host "      cd ..\mobile; flutter pub get"
Write-Host "      cd ..\web; flutter pub get"
Write-Host "   3. Tester les applications :"
Write-Host "      cd packages\mobile; flutter run"
Write-Host "      cd packages\web; flutter run -d chrome"
Write-Host ""
Write-Host "⚠️  Note: Le code original dans lib/ n'a pas été supprimé." -ForegroundColor Yellow
Write-Host "   Vous pouvez le supprimer manuellement après vérification."

