# Script d'initialisation Git pour CampBnb (PowerShell)
# Usage: .\scripts\init_git.ps1

Write-Host "🚀 Initialisation du repository Git pour CampBnb..." -ForegroundColor Cyan

# Vérifier si Git est installé
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git n'est pas installé" -ForegroundColor Red
    exit 1
}

# Vérifier si on est déjà dans un repo Git
if (Test-Path .git) {
    Write-Host "⚠️  Un repository Git existe déjà" -ForegroundColor Yellow
    $response = Read-Host "Voulez-vous continuer ? (y/n)"
    if ($response -ne "y" -and $response -ne "Y") {
        exit 1
    }
}

# Initialiser Git si nécessaire
if (-not (Test-Path .git)) {
    Write-Host "📦 Initialisation de Git..." -ForegroundColor Green
    git init
}

# Ajouter tous les fichiers
Write-Host "📝 Ajout des fichiers..." -ForegroundColor Green
git add .

# Créer le premier commit
Write-Host "💾 Création du premier commit..." -ForegroundColor Green
try {
    git commit -m "first commit: Infrastructure GitHub complète pour CampBnb"
} catch {
    Write-Host "⚠️  Aucun changement à commiter" -ForegroundColor Yellow
}

# Renommer la branche en main
Write-Host "🌿 Configuration de la branche main..." -ForegroundColor Green
git branch -M main

# Vérifier si le remote existe déjà
try {
    $remoteUrl = git remote get-url origin 2>$null
    if ($remoteUrl) {
        Write-Host "⚠️  Le remote 'origin' existe déjà" -ForegroundColor Yellow
        $response = Read-Host "Voulez-vous le remplacer ? (y/n)"
        if ($response -eq "y" -or $response -eq "Y") {
            git remote remove origin
            git remote add origin https://github.com/Endsi3g/CampBnb.git
        }
    }
} catch {
    Write-Host "🔗 Ajout du remote origin..." -ForegroundColor Green
    git remote add origin https://github.com/Endsi3g/CampBnb.git
}

Write-Host ""
Write-Host "✅ Initialisation terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Prochaines étapes :" -ForegroundColor Cyan
Write-Host "1. Créez le repository sur GitHub : https://github.com/new"
Write-Host "   - Nom : CampBnb"
Write-Host "   - Visibilité : Public ou Private"
Write-Host "   - NE PAS initialiser avec README, .gitignore ou license"
Write-Host ""
Write-Host "2. Poussez le code :"
Write-Host "   git push -u origin main"
Write-Host ""
Write-Host "3. Configurez les secrets GitHub (voir docs/SETUP.md)"
Write-Host "4. Configurez les branch protection rules"
Write-Host "5. Exécutez scripts/setup_labels.sh pour configurer les labels"

