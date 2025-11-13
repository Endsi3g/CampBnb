# Script pour trouver Flutter sur le système
# Usage: .\scripts\find_flutter.ps1

Write-Host "🔍 Recherche de Flutter..." -ForegroundColor Cyan
Write-Host ""

# Emplacements courants
$searchPaths = @(
    "C:\src\flutter",
    "C:\flutter",
    "$env:USERPROFILE\flutter",
    "$env:USERPROFILE\AppData\Local\flutter",
    "C:\Program Files\flutter",
    "C:\Program Files (x86)\flutter",
    "C:\tools\flutter",
    "D:\flutter",
    "D:\src\flutter"
)

$found = $false

Write-Host "Recherche dans les emplacements courants..." -ForegroundColor Yellow
foreach ($path in $searchPaths) {
    $flutterExe = Join-Path $path "bin\flutter.exe"
    if (Test-Path $flutterExe) {
        Write-Host "✅ Trouvé: $flutterExe" -ForegroundColor Green
        Write-Host "   Chemin à ajouter au PATH: $(Join-Path $path 'bin')" -ForegroundColor Yellow
        Write-Host ""
        $found = $true
    }
}

# Vérifier dans le PATH actuel
Write-Host "Vérification du PATH actuel..." -ForegroundColor Yellow
$pathEntries = $env:Path -split ';'
foreach ($entry in $pathEntries) {
    if ($entry -like '*flutter*') {
        $flutterExe = Join-Path $entry "flutter.exe"
        if (Test-Path $flutterExe) {
            Write-Host "✅ Trouvé dans PATH: $flutterExe" -ForegroundColor Green
            Write-Host ""
            $found = $true
        }
    }
}

# Recherche récursive (optionnelle - peut être lent)
if (-not $found) {
    Write-Host "Flutter non trouvé dans les emplacements courants." -ForegroundColor Yellow
    Write-Host ""
    $search = Read-Host "Voulez-vous faire une recherche approfondie? (O/N)"
    
    if ($search -eq 'O' -or $search -eq 'o') {
        Write-Host "Recherche approfondie (peut prendre plusieurs minutes)..." -ForegroundColor Cyan
        Write-Host "Recherche dans: C:\Users\$env:USERNAME" -ForegroundColor Gray
        
        $foundFiles = Get-ChildItem -Path "C:\Users\$env:USERNAME" -Filter flutter.exe -Recurse -ErrorAction SilentlyContinue -Depth 4 | Select-Object -First 10
        
        if ($foundFiles) {
            Write-Host ""
            Write-Host "✅ Flutter trouvé:" -ForegroundColor Green
            foreach ($file in $foundFiles) {
                Write-Host "   $($file.FullName)" -ForegroundColor Green
                $binPath = $file.DirectoryName
                Write-Host "   Chemin à ajouter au PATH: $binPath" -ForegroundColor Yellow
                Write-Host ""
            }
            $found = $true
        }
    }
}

if (-not $found) {
    Write-Host ""
    Write-Host "❌ Flutter non trouvé sur le système." -ForegroundColor Red
    Write-Host ""
    Write-Host "📥 Installation nécessaire:" -ForegroundColor Cyan
    Write-Host "1. Aller sur: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Télécharger Flutter SDK" -ForegroundColor White
    Write-Host "3. Extraire dans C:\src\flutter" -ForegroundColor White
    Write-Host "4. Ajouter C:\src\flutter\bin au PATH" -ForegroundColor White
    Write-Host ""
    Write-Host "Voir docs/FIND_OR_INSTALL_FLUTTER.md pour les détails" -ForegroundColor Yellow
} else {
    Write-Host "✅ Pour ajouter au PATH de cette session:" -ForegroundColor Cyan
    Write-Host '   $env:Path += ";CHEMIN_VERS_FLUTTER\bin"' -ForegroundColor Gray
    Write-Host ""
    Write-Host "✅ Pour rendre permanent:" -ForegroundColor Cyan
    Write-Host "   1. Win+R → sysdm.cpl" -ForegroundColor Gray
    Write-Host "   2. Advanced → Environment Variables" -ForegroundColor Gray
    Write-Host "   3. Path → Edit → New" -ForegroundColor Gray
    Write-Host "   4. Ajouter: CHEMIN_VERS_FLUTTER\bin" -ForegroundColor Gray
}

