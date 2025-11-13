# Script pour résoudre l'erreur de push Git
# Usage: .\scripts\fix_git_push.ps1

Write-Host "🔧 Configuration Git et résolution du problème de push..." -ForegroundColor Cyan

# Vérifier si Git est configuré
$gitName = git config --global user.name 2>$null
$gitEmail = git config --global user.email 2>$null

if (-not $gitName -or -not $gitEmail) {
    Write-Host "⚠️  Git n'est pas configuré" -ForegroundColor Yellow
    Write-Host "Configuration de Git..." -ForegroundColor Green
    
    # Demander les informations
    if (-not $gitName) {
        $name = Read-Host "Entrez votre nom (ou appuyez sur Entrée pour 'Endsi3g')"
        if ([string]::IsNullOrWhiteSpace($name)) {
            $name = "Endsi3g"
        }
        git config --global user.name $name
    }
    
    if (-not $gitEmail) {
        $email = Read-Host "Entrez votre email (ou appuyez sur Entrée pour 'endsi3g@users.noreply.github.com')"
        if ([string]::IsNullOrWhiteSpace($email)) {
            $email = "endsi3g@users.noreply.github.com"
        }
        git config --global user.email $email
    }
    
    Write-Host "✅ Git configuré" -ForegroundColor Green
}

# Vérifier l'état
Write-Host "`n📊 État actuel:" -ForegroundColor Cyan
git status --short

# Vérifier s'il y a des fichiers stagés
$stagedFiles = git diff --cached --name-only
if ($stagedFiles) {
    Write-Host "`n💾 Création du commit..." -ForegroundColor Green
    git commit -m "first commit: Infrastructure GitHub complète pour CampBnb"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Commit créé avec succès!" -ForegroundColor Green
        
        Write-Host "`n🚀 Push vers GitHub..." -ForegroundColor Green
        git push -u origin main
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n🎉 SUCCÈS! Le repository a été poussé sur GitHub!" -ForegroundColor Green
            Write-Host "Repository: https://github.com/Endsi3g/CampBnb" -ForegroundColor Cyan
        } else {
            Write-Host "`n❌ Erreur lors du push. Vérifiez:" -ForegroundColor Red
            Write-Host "1. Le repository existe sur GitHub" -ForegroundColor Yellow
            Write-Host "2. Vous avez les permissions" -ForegroundColor Yellow
            Write-Host "3. L'authentification est configurée" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Erreur lors de la création du commit" -ForegroundColor Red
    }
} else {
    Write-Host "`n⚠️  Aucun fichier stagé. Ajout de tous les fichiers..." -ForegroundColor Yellow
    git add .
    git commit -m "first commit: Infrastructure GitHub complète pour CampBnb"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Commit créé!" -ForegroundColor Green
        Write-Host "`n🚀 Push vers GitHub..." -ForegroundColor Green
        git push -u origin main
    }
}

