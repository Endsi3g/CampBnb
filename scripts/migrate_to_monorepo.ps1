# Script de migration vers le monorepo (PowerShell)
# Usage: .\scripts\migrate_to_monorepo.ps1

param(
    [switch]$SkipExisting
)

$ErrorActionPreference = "Stop"

# Obtenir le répertoire du script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

# Changer vers le répertoire racine du projet
Set-Location $ProjectRoot

Write-Host "Migration vers le monorepo Campbnb Quebec..." -ForegroundColor Green

# Vérifier que nous sommes à la racine du projet
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "ERREUR: Ce script doit etre execute a la racine du projet" -ForegroundColor Red
    Write-Host "Repertoire actuel: $ProjectRoot" -ForegroundColor Yellow
    exit 1
}

# Créer la structure si elle n'existe pas
Write-Host "Creation de la structure..." -ForegroundColor Yellow
$sharedLibPath = "packages\shared\lib"
$sharedAssetsPath = "packages\shared\assets"

if (-not (Test-Path $sharedLibPath)) {
    New-Item -ItemType Directory -Force -Path $sharedLibPath | Out-Null
    Write-Host "  Cree: $sharedLibPath" -ForegroundColor Gray
}

if (-not (Test-Path $sharedAssetsPath)) {
    New-Item -ItemType Directory -Force -Path $sharedAssetsPath | Out-Null
    Write-Host "  Cree: $sharedAssetsPath" -ForegroundColor Gray
}

# Fonction pour copier un dossier
function Copy-DirectoryIfExists {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description
    )
    
    if (Test-Path $Source) {
        Write-Host "$Description..." -ForegroundColor Yellow
        
        # Vérifier si la destination existe déjà
        if ((Test-Path $Destination) -and -not $SkipExisting) {
            Write-Host "  ATTENTION: $Destination existe deja. Utilisez -SkipExisting pour ecraser." -ForegroundColor Yellow
            return
        }
        
        # Supprimer la destination si elle existe et qu'on veut écraser
        if ((Test-Path $Destination) -and $SkipExisting) {
            Remove-Item -Path $Destination -Recurse -Force
        }
        
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        Write-Host "  OK: $Source -> $Destination" -ForegroundColor Green
    } else {
        Write-Host "  SKIP: $Source n'existe pas" -ForegroundColor Gray
    }
}

# Déplacer le code
Copy-DirectoryIfExists -Source "lib\core" -Destination "$sharedLibPath\core" -Description "Deplacement de lib/core"
Copy-DirectoryIfExists -Source "lib\features" -Destination "$sharedLibPath\features" -Description "Deplacement de lib/features"
Copy-DirectoryIfExists -Source "lib\shared" -Destination "$sharedLibPath\shared" -Description "Deplacement de lib/shared"

# Déplacer les assets
if (Test-Path "assets") {
    Write-Host "Deplacement des assets..." -ForegroundColor Yellow
    
    if ((Test-Path $sharedAssetsPath) -and -not $SkipExisting) {
        Write-Host "  ATTENTION: $sharedAssetsPath existe deja. Utilisez -SkipExisting pour ecraser." -ForegroundColor Yellow
    } else {
        if ((Test-Path $sharedAssetsPath) -and $SkipExisting) {
            Remove-Item -Path $sharedAssetsPath -Recurse -Force
        }
        Copy-Item -Path "assets" -Destination "packages\shared\" -Recurse -Force
        Write-Host "  OK: assets -> packages\shared\assets" -ForegroundColor Green
    }
} else {
    Write-Host "  SKIP: assets n'existe pas" -ForegroundColor Gray
}

# Déplacer les fichiers de configuration si nécessaire
if (Test-Path "analysis_options.yaml") {
    Write-Host "Copie de analysis_options.yaml..." -ForegroundColor Yellow
    $destPath = "packages\shared\analysis_options.yaml"
    
    if ((Test-Path $destPath) -and -not $SkipExisting) {
        Write-Host "  ATTENTION: $destPath existe deja. Utilisez -SkipExisting pour ecraser." -ForegroundColor Yellow
    } else {
        Copy-Item -Path "analysis_options.yaml" -Destination $destPath -Force
        Write-Host "  OK: analysis_options.yaml -> $destPath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Migration terminee!" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes :" -ForegroundColor Cyan
Write-Host "  1. Verifier que le code a ete correctement deplace"
Write-Host "  2. Installer les dependances :"
Write-Host "     cd packages\shared"
Write-Host "     flutter pub get"
Write-Host "     cd ..\mobile"
Write-Host "     flutter pub get"
Write-Host "     cd ..\web"
Write-Host "     flutter pub get"
Write-Host "  3. Tester les applications :"
Write-Host "     cd packages\mobile"
Write-Host "     flutter run"
Write-Host "     cd ..\web"
Write-Host "     flutter run -d chrome"
Write-Host ""
Write-Host "NOTE: Le code original dans lib/ n'a pas ete supprime." -ForegroundColor Yellow
Write-Host "     Vous pouvez le supprimer manuellement apres verification."

