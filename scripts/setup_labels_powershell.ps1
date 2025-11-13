# Script PowerShell pour configurer les labels GitHub
# Usage: .\scripts\setup_labels_powershell.ps1

Write-Host "🏷️  Configuration des labels GitHub pour CampBnb..." -ForegroundColor Cyan

# Vérifier que gh CLI est installé
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI (gh) n'est pas installé" -ForegroundColor Red
    Write-Host "Installez-le depuis: https://cli.github.com/" -ForegroundColor Yellow
    Write-Host "Ou utilisez: winget install GitHub.cli" -ForegroundColor Yellow
    exit 1
}

# Vérifier l'authentification
try {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Vous n'êtes pas authentifié avec GitHub CLI" -ForegroundColor Red
        Write-Host "Exécutez: gh auth login" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification de l'authentification" -ForegroundColor Red
    exit 1
}

# Vérifier que le fichier labels.json existe
$labelsFile = ".github/labels.json"
if (-not (Test-Path $labelsFile)) {
    Write-Host "❌ Fichier $labelsFile introuvable" -ForegroundColor Red
    exit 1
}

Write-Host "📖 Lecture du fichier labels.json..." -ForegroundColor Green

# Lire le fichier JSON
try {
    $labels = Get-Content $labelsFile -Raw | ConvertFrom-Json
} catch {
    Write-Host "❌ Erreur lors de la lecture du fichier JSON" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "✅ $($labels.Count) labels trouvés" -ForegroundColor Green
Write-Host ""

$successCount = 0
$errorCount = 0
$updateCount = 0

# Créer ou mettre à jour chaque label
foreach ($label in $labels) {
    $name = $label.name
    $color = $label.color
    $description = if ($label.description) { $label.description } else { "" }
    
    if ([string]::IsNullOrWhiteSpace($name) -or $name -eq "null") {
        continue
    }
    
    Write-Host "  📌 Label: $name" -ForegroundColor Cyan
    
    # Essayer de créer le label
    $createOutput = gh label create $name --color $color --description $description --force 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✅ Créé avec succès" -ForegroundColor Green
        $successCount++
    } else {
        # Essayer de mettre à jour le label existant
        $editOutput = gh label edit $name --color $color --description $description 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    🔄 Mis à jour" -ForegroundColor Yellow
            $updateCount++
        } else {
            Write-Host "    ⚠️  Erreur: $($editOutput -join ' ')" -ForegroundColor Red
            $errorCount++
        }
    }
}

Write-Host ""
Write-Host "📊 Résumé:" -ForegroundColor Cyan
Write-Host "  ✅ Créés: $successCount" -ForegroundColor Green
Write-Host "  🔄 Mis à jour: $updateCount" -ForegroundColor Yellow
Write-Host "  ❌ Erreurs: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })

if ($errorCount -eq 0) {
    Write-Host ""
    Write-Host "🎉 Tous les labels ont été configurés avec succès !" -ForegroundColor Green
    Write-Host "Vérifiez sur: https://github.com/Endsi3g/CampBnb/labels" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "⚠️  Certains labels n'ont pas pu être configurés" -ForegroundColor Yellow
    Write-Host "Vérifiez vos permissions et votre authentification GitHub" -ForegroundColor Yellow
}

