# Script pour ajouter Flutter au PATH temporairement
# Usage: .\scripts\setup_flutter_path.ps1

Write-Host "🔧 Configuration du PATH Flutter" -ForegroundColor Cyan
Write-Host ""

# Chemins courants où Flutter peut être installé
$commonPaths = @(
    "C:\src\flutter\bin",
    "C:\flutter\bin",
    "$env:USERPROFILE\flutter\bin",
    "C:\Program Files\flutter\bin",
    "C:\tools\flutter\bin"
)

$flutterPath = $null

# Chercher Flutter dans les chemins courants
foreach ($path in $commonPaths) {
    if (Test-Path "$path\flutter.exe") {
        $flutterPath = $path
        Write-Host "✅ Flutter trouvé: $path" -ForegroundColor Green
        break
    }
}

# Si non trouvé, demander à l'utilisateur
if (-not $flutterPath) {
    Write-Host "❌ Flutter non trouvé dans les emplacements courants" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Où est installé Flutter?" -ForegroundColor Cyan
    Write-Host "Exemple: C:\src\flutter" -ForegroundColor Gray
    $userPath = Read-Host "Chemin vers le dossier Flutter"
    
    if ($userPath) {
        $flutterBinPath = Join-Path $userPath "bin"
        if (Test-Path "$flutterBinPath\flutter.exe") {
            $flutterPath = $flutterBinPath
            Write-Host "✅ Flutter trouvé: $flutterPath" -ForegroundColor Green
        } else {
            Write-Host "❌ Flutter.exe non trouvé dans: $flutterBinPath" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Chemin non fourni" -ForegroundColor Red
        exit 1
    }
}

# Ajouter au PATH de la session
$env:Path += ";$flutterPath"
Write-Host ""
Write-Host "✅ Flutter ajouté au PATH pour cette session" -ForegroundColor Green
Write-Host ""

# Vérifier
Write-Host "🧪 Vérification..." -ForegroundColor Cyan
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✅ Flutter fonctionne: $flutterVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Pour rendre permanent:" -ForegroundColor Yellow
    Write-Host "   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Gray
    Write-Host "   Puis ajouter manuellement au PATH système" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur: $_" -ForegroundColor Red
    exit 1
}

