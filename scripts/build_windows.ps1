# Script de build pour Windows - Campbnb Québec
# Ce script construit l'application Flutter pour Windows

param(
    [string]$Mode = "release",
    [switch]$Clean = $false,
    [switch]$Build = $true,
    [switch]$Package = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build Windows - Campbnb Québec" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Flutter est installé
Write-Host "Vérification de Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version
    Write-Host "Flutter détecté" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Flutter n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    exit 1
}

# Vérifier que Visual Studio est installé
Write-Host "Vérification de Visual Studio..." -ForegroundColor Yellow
$vsPath = Get-ChildItem "C:\Program Files\Microsoft Visual Studio" -ErrorAction SilentlyContinue
if (-not $vsPath) {
    Write-Host "AVERTISSEMENT: Visual Studio n'a pas été trouvé. Assurez-vous qu'il est installé." -ForegroundColor Yellow
} else {
    Write-Host "Visual Studio détecté" -ForegroundColor Green
}

# Nettoyer si demandé
if ($Clean) {
    Write-Host ""
    Write-Host "Nettoyage du projet..." -ForegroundColor Yellow
    flutter clean
    Remove-Item -Path "build\windows" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Nettoyage terminé" -ForegroundColor Green
}

# Obtenir les dépendances
Write-Host ""
Write-Host "Récupération des dépendances..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: Échec de la récupération des dépendances" -ForegroundColor Red
    exit 1
}
Write-Host "Dépendances récupérées" -ForegroundColor Green

# Build si demandé
if ($Build) {
    Write-Host ""
    Write-Host "Construction de l'application ($Mode)..." -ForegroundColor Yellow
    
    $buildCommand = "flutter build windows --$Mode"
    if ($Mode -eq "release") {
        $buildCommand += " --release"
    }
    
    Invoke-Expression $buildCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERREUR: Échec de la construction" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Construction terminée avec succès!" -ForegroundColor Green
    Write-Host "Exécutable: build\windows\$Mode\runner\campbnb_quebec.exe" -ForegroundColor Cyan
}

# Package si demandé
if ($Package) {
    Write-Host ""
    Write-Host "Création du package..." -ForegroundColor Yellow
    
    $buildDir = "build\windows\$Mode\runner"
    $packageDir = "build\windows\package"
    
    if (Test-Path $packageDir) {
        Remove-Item -Path $packageDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
    
    # Copier les fichiers nécessaires
    Copy-Item -Path "$buildDir\*" -Destination $packageDir -Recurse -Force
    
    # Créer un ZIP
    $zipPath = "build\windows\campbnb_quebec_windows_$Mode.zip"
    if (Test-Path $zipPath) {
        Remove-Item -Path $zipPath -Force
    }
    
    Write-Host "Création de l'archive ZIP..." -ForegroundColor Yellow
    Compress-Archive -Path "$packageDir\*" -DestinationPath $zipPath -Force
    
    Write-Host "Package créé: $zipPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build terminé avec succès!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

