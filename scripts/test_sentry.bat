@echo off
REM Script Batch pour tester la capture d'erreurs Sentry
REM Alternative au script PowerShell pour éviter les problèmes de politique d'exécution

echo ========================================
echo   Test de capture d'erreurs Sentry
echo ========================================
echo.

REM Vérifier que Flutter est disponible
where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Flutter n'est pas dans le PATH
    echo.
    echo Voir docs/POWERSHELL_FLUTTER_SETUP.md pour la configuration
    pause
    exit /b 1
)

echo [OK] Flutter trouve
echo.

REM Vérifier SENTRY_DSN
if "%SENTRY_DSN%"=="" (
    echo [ATTENTION] SENTRY_DSN non configure
    echo.
    echo Definir avec: set SENTRY_DSN=https://your-dsn@sentry.io/project-id
    echo.
)

echo Options de test:
echo 1. Executer les tests unitaires
echo 2. Lancer l'application en mode debug
echo 3. Verifier la configuration Sentry
echo.
set /p choice="Choisir une option (1-3): "

if "%choice%"=="1" (
    echo.
    echo [TEST] Execution des tests unitaires...
    echo.
    flutter test test/monitoring/error_capture_test.dart
    goto :end
)

if "%choice%"=="2" (
    echo.
    echo [LANCEMENT] Application en mode debug...
    echo Les erreurs seront capturees automatiquement
    echo.
    flutter run
    goto :end
)

if "%choice%"=="3" (
    echo.
    echo [CONFIGURATION] Verification de la configuration...
    echo.
    echo SENTRY_DSN: %SENTRY_DSN%
    echo.
    echo Pour configurer:
    echo 1. Creer un compte sur https://sentry.io
    echo 2. Creer un projet Flutter
    echo 3. Recuperer le DSN
    echo 4. Definir: set SENTRY_DSN=your-dsn
    echo.
    goto :end
)

echo [ERREUR] Option invalide
goto :end

:end
echo.
echo ========================================
echo   Verifier les erreurs dans Sentry:
echo   https://sentry.io/organizations/your-org/issues/
echo ========================================
echo.
pause

