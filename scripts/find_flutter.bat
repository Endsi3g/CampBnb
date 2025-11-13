@echo off
REM Script Batch pour trouver Flutter sur le système
REM Usage: .\scripts\find_flutter.bat

echo ========================================
echo   Recherche de Flutter
echo ========================================
echo.

set "FOUND=0"

REM Emplacements courants
echo Recherche dans les emplacements courants...
echo.

if exist "C:\src\flutter\bin\flutter.exe" (
    echo [OK] Trouve: C:\src\flutter\bin\flutter.exe
    echo    Chemin a ajouter au PATH: C:\src\flutter\bin
    echo.
    set "FOUND=1"
)
if exist "C:\flutter\bin\flutter.exe" (
    echo [OK] Trouve: C:\flutter\bin\flutter.exe
    echo    Chemin a ajouter au PATH: C:\flutter\bin
    echo.
    set "FOUND=1"
)
if exist "%USERPROFILE%\flutter\bin\flutter.exe" (
    echo [OK] Trouve: %USERPROFILE%\flutter\bin\flutter.exe
    echo    Chemin a ajouter au PATH: %USERPROFILE%\flutter\bin
    echo.
    set "FOUND=1"
)
if exist "%USERPROFILE%\AppData\Local\flutter\bin\flutter.exe" (
    echo [OK] Trouve: %USERPROFILE%\AppData\Local\flutter\bin\flutter.exe
    echo    Chemin a ajouter au PATH: %USERPROFILE%\AppData\Local\flutter\bin
    echo.
    set "FOUND=1"
)
if exist "C:\Program Files\flutter\bin\flutter.exe" (
    echo [OK] Trouve: C:\Program Files\flutter\bin\flutter.exe
    echo    Chemin a ajouter au PATH: C:\Program Files\flutter\bin
    echo.
    set "FOUND=1"
)
if exist "C:\tools\flutter\bin\flutter.exe" (
    echo [OK] Trouve: C:\tools\flutter\bin\flutter.exe
    echo    Chemin a ajouter au PATH: C:\tools\flutter\bin
    echo.
    set "FOUND=1"
)

REM Verifier dans le PATH
echo Verification du PATH actuel...
echo.
echo %PATH% | findstr /i "flutter" >nul
if errorlevel 1 (
    echo [INFO] Flutter non trouve dans le PATH actuel
) else (
    echo [OK] Flutter trouve dans le PATH
    set "FOUND=1"
)

if "%FOUND%"=="0" (
    echo.
    echo [ATTENTION] Flutter non trouve dans les emplacements courants
    echo.
    echo Options:
    echo 1. Flutter est installe ailleurs
    echo 2. Flutter n'est pas installe
    echo.
    echo Pour installer Flutter:
    echo 1. Aller sur: https://docs.flutter.dev/get-started/install/windows
    echo 2. Telecharger Flutter SDK
    echo 3. Extraire dans C:\src\flutter
    echo 4. Ajouter C:\src\flutter\bin au PATH
    echo.
    echo Voir docs/FIND_OR_INSTALL_FLUTTER.md pour les details
) else (
    echo.
    echo ========================================
    echo   Pour ajouter au PATH de cette session:
    echo   set PATH=%%PATH%%;CHEMIN_VERS_FLUTTER\bin
    echo.
    echo   Pour rendre permanent:
    echo   1. Win+R, taper: sysdm.cpl
    echo   2. Avance -^> Variables d'environnement
    echo   3. Path -^> Modifier -^> Nouveau
    echo   4. Ajouter: CHEMIN_VERS_FLUTTER\bin
    echo ========================================
)

echo.
pause

