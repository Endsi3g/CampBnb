# Script de build MSIX pour Windows - Campbnb Québec
# Ce script crée un package MSIX pour le Microsoft Store

param(
    [string]$Version = "1.0.0",
    [string]$Publisher = "CN=Campbnb Quebec"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build MSIX - Campbnb Québec" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Flutter est installé
Write-Host "Vérification de Flutter..." -ForegroundColor Yellow
try {
    flutter --version | Out-Null
    Write-Host "Flutter détecté" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Flutter n'est pas installé" -ForegroundColor Red
    exit 1
}

# Vérifier que makeappx.exe est disponible (Windows SDK)
$makeappx = Get-Command "makeappx.exe" -ErrorAction SilentlyContinue
if (-not $makeappx) {
    Write-Host "ERREUR: makeappx.exe (Windows SDK) n'est pas trouvé dans le PATH" -ForegroundColor Red
    Write-Host "Installez le Windows SDK avec l'outil makeappx" -ForegroundColor Yellow
    exit 1
}

# Build release d'abord
Write-Host ""
Write-Host "Construction de l'application (release)..." -ForegroundColor Yellow
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: Échec de la construction" -ForegroundColor Red
    exit 1
}

# Créer le répertoire pour le package MSIX
$msixDir = "build\windows\msix"
if (Test-Path $msixDir) {
    Remove-Item -Path $msixDir -Recurse -Force
}
New-Item -ItemType Directory -Path $msixDir -Force | Out-Null

# Créer la structure AppX
$appxDir = "$msixDir\AppX"
New-Item -ItemType Directory -Path $appxDir -Force | Out-Null

# Copier les fichiers de l'application
$buildDir = "build\windows\release\runner"
Write-Host "Copie des fichiers de l'application..." -ForegroundColor Yellow
Copy-Item -Path "$buildDir\*" -Destination $appxDir -Recurse -Force

# Créer le manifest AppXManifest.xml
Write-Host "Création du manifest AppXManifest.xml..." -ForegroundColor Yellow
$manifest = @"
<?xml version="1.0" encoding="utf-8"?>
<Package xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
         xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
         xmlns:uap3="http://schemas.microsoft.com/appx/manifest/uap/windows10/3"
         xmlns:desktop="http://schemas.microsoft.com/appx/manifest/desktop/windows10"
         IgnorableNamespaces="uap uap3 desktop">
  <Identity Name="CampbnbQuebec"
            Version="$Version.0"
            Publisher="$Publisher" />
  <Properties>
    <DisplayName>Campbnb Québec</DisplayName>
    <PublisherDisplayName>Campbnb Québec</PublisherDisplayName>
    <Description>Plateforme de réservation de campings au Québec</Description>
    <Logo>Assets\StoreLogo.png</Logo>
  </Properties>
  <Resources>
    <Resource Language="fr-CA" />
    <Resource Language="en-US" />
  </Resources>
  <Dependencies>
    <TargetDeviceFamily Name="Windows.Desktop" MinVersion="10.0.17763.0" MaxVersionTested="10.0.22621.0" />
  </Dependencies>
  <Applications>
    <Application Id="App"
                 Executable="campbnb_quebec.exe"
                 EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements DisplayName="Campbnb Québec"
                         Description="Plateforme de réservation de campings au Québec"
                         Square150x150Logo="Assets\Square150x150Logo.png"
                         Square44x44Logo="Assets\Square44x44Logo.png"
                         BackgroundColor="#2E7D32">
        <uap:DefaultTile Wide310x150Logo="Assets\Wide310x150Logo.png" />
      </uap:VisualElements>
      <Extensions>
        <desktop:Extension Category="windows.fullTrustProcess" EntryPoint="Windows.FullTrustApplication">
          <desktop:FullTrustProcess>
            <desktop:ParameterGroup GroupId="Install" Parameters="/Install" />
          </desktop:FullTrustProcess>
        </desktop:Extension>
      </Extensions>
    </Application>
  </Applications>
</Package>
"@

$manifestPath = "$appxDir\AppXManifest.xml"
$manifest | Out-File -FilePath $manifestPath -Encoding UTF8

# Créer le package MSIX
Write-Host "Création du package MSIX..." -ForegroundColor Yellow
$msixPath = "$msixDir\campbnb_quebec_$Version.msix"
makeappx.exe pack /d $appxDir /p $msixPath /o

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: Échec de la création du package MSIX" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Package MSIX créé avec succès!" -ForegroundColor Green
Write-Host "Fichier: $msixPath" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

