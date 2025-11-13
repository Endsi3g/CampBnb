# Script PowerShell pour finaliser la mise en place de la sécurité
# Campbnb Québec - Setup Sécurité

Write-Host "🔒 Configuration de la sécurité - Campbnb Québec" -ForegroundColor Cyan
Write-Host ""

# Vérifier que nous sommes dans le bon répertoire
if ($MyInvocation.MyCommand.Path) {
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $projectRoot = Split-Path -Parent $scriptPath
} else {
    $projectRoot = Get-Location
    $scriptPath = Join-Path $projectRoot "scripts"
}
Set-Location $projectRoot

Write-Host "📦 1. Installation des dépendances Flutter..." -ForegroundColor Yellow
try {
    flutter pub get
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dépendances installées avec succès" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️  Flutter n'est pas dans le PATH. Veuillez installer Flutter ou l'ajouter au PATH." -ForegroundColor Yellow
    Write-Host "   Commande à exécuter manuellement: flutter pub get" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🗄️  2. Application des migrations Supabase..." -ForegroundColor Yellow
try {
    supabase db push
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Migrations appliquées avec succès" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur lors de l'application des migrations" -ForegroundColor Red
        Write-Host "   Assurez-vous d'être connecté à Supabase: supabase login" -ForegroundColor Gray
        Write-Host "   Et d'avoir lié le projet: supabase link --project-ref your-project-ref" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  Supabase CLI n'est pas installé ou n'est pas dans le PATH." -ForegroundColor Yellow
    Write-Host "   Installation: npm install -g supabase" -ForegroundColor Gray
    Write-Host "   Commande à exécuter manuellement: supabase db push" -ForegroundColor Gray
}

Write-Host ""
Write-Host "⚡ 3. Déploiement de l'Edge Function de sécurité..." -ForegroundColor Yellow
try {
    supabase functions deploy security
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Edge Function déployée avec succès" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur lors du déploiement de l'Edge Function" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️  Erreur lors du déploiement." -ForegroundColor Yellow
    Write-Host "   Commande à exécuter manuellement: supabase functions deploy security" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🛡️  4. Exécution de l'audit de sécurité..." -ForegroundColor Yellow
$auditScript = Join-Path $scriptPath "security_audit.sh"
if (Test-Path $auditScript) {
    # Pour Windows, nous devons utiliser Git Bash ou WSL pour exécuter le script bash
    Write-Host "   Le script d'audit est un script bash (.sh)" -ForegroundColor Gray
    Write-Host "   Options pour l'exécuter:" -ForegroundColor Gray
    Write-Host "   1. Utiliser Git Bash: bash scripts/security_audit.sh" -ForegroundColor Gray
    Write-Host "   2. Utiliser WSL: wsl bash scripts/security_audit.sh" -ForegroundColor Gray
    Write-Host "   3. Exécuter manuellement les vérifications" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Script d'audit non trouvé: $auditScript" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ Configuration terminée!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Checklist de vérification:" -ForegroundColor Yellow
Write-Host "   [ ] Dépendances Flutter installées" -ForegroundColor Gray
Write-Host "   [ ] Migrations SQL appliquées" -ForegroundColor Gray
Write-Host "   [ ] Edge Function de sécurité déployée" -ForegroundColor Gray
Write-Host "   [ ] Audit de sécurité exécuté" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Yellow
Write-Host "   - docs/SECURITY_QUICK_START.md" -ForegroundColor Gray
Write-Host "   - docs/SECURITY.md" -ForegroundColor Gray
Write-Host "   - docs/COMPLIANCE.md" -ForegroundColor Gray
Write-Host ""

