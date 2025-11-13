@echo off
REM Script batch pour finaliser la mise en place de la sécurité
REM Campbnb Québec - Setup Sécurité

echo.
echo 🔒 Configuration de la sécurité - Campbnb Québec
echo.

cd /d "%~dp0\.."

echo 📦 1. Installation des dépendances Flutter...
flutter pub get
if %ERRORLEVEL% EQU 0 (
    echo ✅ Dépendances installées avec succès
) else (
    echo ⚠️  Flutter n'est pas dans le PATH ou erreur lors de l'installation
    echo    Commande à exécuter manuellement: flutter pub get
)

echo.
echo 🗄️  2. Application des migrations Supabase...
supabase db push
if %ERRORLEVEL% EQU 0 (
    echo ✅ Migrations appliquées avec succès
) else (
    echo ⚠️  Supabase CLI n'est pas installé ou erreur lors de l'application
    echo    Assurez-vous d'être connecté: supabase login
    echo    Et d'avoir lié le projet: supabase link --project-ref your-project-ref
    echo    Commande à exécuter manuellement: supabase db push
)

echo.
echo ⚡ 3. Déploiement de l'Edge Function de sécurité...
supabase functions deploy security
if %ERRORLEVEL% EQU 0 (
    echo ✅ Edge Function déployée avec succès
) else (
    echo ⚠️  Erreur lors du déploiement
    echo    Commande à exécuter manuellement: supabase functions deploy security
)

echo.
echo 🛡️  4. Exécution de l'audit de sécurité...
echo    Le script d'audit est un script bash (.sh)
echo    Options pour l'exécuter:
echo    1. Utiliser Git Bash: bash scripts/security_audit.sh
echo    2. Utiliser WSL: wsl bash scripts/security_audit.sh
echo    3. Exécuter manuellement les vérifications

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ✅ Configuration terminée!
echo.
echo 📋 Checklist de vérification:
echo    [ ] Dépendances Flutter installées
echo    [ ] Migrations SQL appliquées
echo    [ ] Edge Function de sécurité déployée
echo    [ ] Audit de sécurité exécuté
echo.
echo 📚 Documentation:
echo    - docs/SECURITY_QUICK_START.md
echo    - docs/SECURITY.md
echo    - docs/COMPLIANCE.md
echo.

pause

