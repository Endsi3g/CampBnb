# Script PowerShell pour injecter le token Mapbox depuis .env dans les fichiers de configuration

# Charger les variables d'environnement depuis .env
if (Test-Path .env) {
    $envContent = Get-Content .env | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '=' }
    foreach ($line in $envContent) {
        $parts = $line -split '=', 2
        if ($parts.Length -eq 2) {
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
} else {
    Write-Host "⚠️  Fichier .env non trouvé. Créez-le avec MAPBOX_ACCESS_TOKEN=your_token" -ForegroundColor Yellow
    exit 1
}

# Vérifier que le token existe
$mapboxToken = $env:MAPBOX_ACCESS_TOKEN
if ([string]::IsNullOrEmpty($mapboxToken)) {
    Write-Host "⚠️  MAPBOX_ACCESS_TOKEN non défini dans .env" -ForegroundColor Yellow
    exit 1
}

Write-Host "🔧 Injection du token Mapbox..." -ForegroundColor Cyan

# Android - strings.xml
$androidStringsPath = "android/app/src/main/res/values/strings.xml"
if (Test-Path $androidStringsPath) {
    $content = Get-Content $androidStringsPath -Raw
    $content = $content -replace "YOUR_MAPBOX_ACCESS_TOKEN", $mapboxToken
    Set-Content -Path $androidStringsPath -Value $content -NoNewline
    Write-Host "✅ Token injecté dans $androidStringsPath" -ForegroundColor Green
} else {
    Write-Host "⚠️  Fichier strings.xml non trouvé" -ForegroundColor Yellow
}

# iOS - Info.plist
$iosInfoPlistPath = "ios/Runner/Info.plist"
if (Test-Path $iosInfoPlistPath) {
    $content = Get-Content $iosInfoPlistPath -Raw
    $content = $content -replace "YOUR_MAPBOX_ACCESS_TOKEN", $mapboxToken
    Set-Content -Path $iosInfoPlistPath -Value $content -NoNewline
    Write-Host "✅ Token injecté dans $iosInfoPlistPath" -ForegroundColor Green
} else {
    Write-Host "⚠️  Fichier Info.plist non trouvé" -ForegroundColor Yellow
}

Write-Host "✅ Injection terminée !" -ForegroundColor Green

