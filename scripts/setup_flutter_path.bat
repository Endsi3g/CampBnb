@echo off
REM Script Batch pour ajouter Flutter au PATH temporairement
REM Usage: .\scripts\setup_flutter_path.bat

echo ========================================
echo   Configuration du PATH Flutter
echo ========================================
echo.

REM Chemins courants
set "FLUTTER_PATH="

REM Chercher Flutter
if exist "C:\src\flutter\bin\flutter.exe" (
    set "FLUTTER_PATH=C:\src\flutter\bin"
    goto :found
)
if exist "C:\flutter\bin\flutter.exe" (
    set "FLUTTER_PATH=C:\flutter\bin"
    goto :found
)
if exist "%USERPROFILE%\flutter\bin\flutter.exe" (
    set "FLUTTER_PATH=%USERPROFILE%\flutter\bin"
    goto :found
)
if exist "C:\Program Files\flutter\bin\flutter.exe" (
    set "FLUTTER_PATH=C:\Program Files\flutter\bin"
    goto :found
)
if exist "C:\tools\flutter\bin\flutter.exe" (
    set "FLUTTER_PATH=C:\tools\flutter\bin"
    goto :found
)

REM Si non trouvé, demander
echo [ATTENTION] Flutter non trouve dans les emplacements courants
echo.
echo Options:
echo 1. Flutter est installe ailleurs - Entrer le chemin
echo 2. Flutter n'est pas installe - Voir docs/FIND_OR_INSTALL_FLUTTER.md
echo.
set /p FLUTTER_DIR="Ou est installe Flutter? (ex: C:\src\flutter ou appuyer Entree pour installer): "

if "%FLUTTER_DIR%"=="" (
    echo.
    echo [INFO] Pour installer Flutter:
    echo 1. Aller sur: https://docs.flutter.dev/get-started/install/windows
    echo 2. Telecharger Flutter SDK
    echo 3. Extraire dans C:\src\flutter
    echo 4. Relancer ce script
    echo.
    echo Voir docs/FIND_OR_INSTALL_FLUTTER.md pour les details
    pause
    exit /b 0
)

if exist "%FLUTTER_DIR%\bin\flutter.exe" (
    set "FLUTTER_PATH=%FLUTTER_DIR%\bin"
    goto :found
) else (
    echo [ERREUR] Flutter.exe non trouve dans %FLUTTER_DIR%\bin
    pause
    exit /b 1
)

:found
echo [OK] Flutter trouve: %FLUTTER_PATH%
echo.

REM Ajouter au PATH de la session
set "PATH=%PATH%;%FLUTTER_PATH%"
echo [OK] Flutter ajoute au PATH pour cette session
echo.

REM Verifier
echo [TEST] Verification...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Flutter ne fonctionne pas
    pause
    exit /b 1
)

echo [OK] Flutter fonctionne!
echo.
echo ========================================
echo   Pour rendre permanent:
echo   1. Win+R, taper: sysdm.cpl
echo   2. Avance -^> Variables d'environnement
echo   3. Path -^> Modifier -^> Nouveau
echo   4. Ajouter: %FLUTTER_PATH%
echo ========================================
echo.
pause

