# Trouver ou Installer Flutter

## 🔍 Flutter n'a pas été trouvé automatiquement

### Option 1: Flutter est installé mais ailleurs

#### Méthode A: Recherche Windows

1. Ouvrir **File Explorer** (Explorateur de fichiers)
2. Dans la barre de recherche, taper: `flutter.exe`
3. Attendre les résultats
4. Quand trouvé, faire **clic droit** → **Ouvrir l'emplacement du fichier**
5. Noter le chemin complet (ex: `C:\Users\Kael\AppData\Local\flutter\bin`)

#### Méthode B: Recherche PowerShell

Dans PowerShell, exécuter:

```powershell
# Rechercher flutter.exe sur tout le disque C:
Get-ChildItem -Path C:\ -Filter flutter.exe -Recurse -ErrorAction SilentlyContinue | Select-Object FullName

# OU recherche plus rapide dans les dossiers utilisateur
Get-ChildItem -Path $env:USERPROFILE -Filter flutter.exe -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
```

**Note**: Cela peut prendre quelques minutes.

#### Méthode C: Vérifier les variables d'environnement

```powershell
# Vérifier si FLUTTER_HOME est défini
$env:FLUTTER_HOME

# Vérifier le PATH actuel
$env:Path -split ';' | Select-String -Pattern 'flutter'
```

### Option 2: Flutter n'est pas installé - Installation

#### Installation Rapide (Recommandé)

1. **Télécharger Flutter**
   - Aller sur: https://docs.flutter.dev/get-started/install/windows
   - Cliquer sur **Download Flutter SDK**
   - Télécharger le fichier ZIP

2. **Extraire Flutter**
   - Créer un dossier: `C:\src` (si n'existe pas)
   - Extraire le ZIP dans `C:\src`
   - Vous devriez avoir: `C:\src\flutter`

3. **Ajouter au PATH**
   - `Win + R` → `sysdm.cpl`
   - **Advanced** → **Environment Variables**
   - **Path** → **Edit** → **New**
   - Ajouter: `C:\src\flutter\bin`
   - **OK** partout

4. **Redémarrer PowerShell**

5. **Vérifier**
   ```powershell
   flutter --version
   flutter doctor
   ```

#### Installation avec Git (Alternative)

Si vous avez Git installé:

```powershell
# Créer le dossier
New-Item -ItemType Directory -Path C:\src -Force

# Cloner Flutter
cd C:\src
git clone https://github.com/flutter/flutter.git -b stable

# Ajouter au PATH (voir ci-dessus)
```

## 📋 Checklist de Vérification

### Si Flutter est installé:

- [ ] Flutter.exe trouvé avec la recherche
- [ ] Chemin noté (ex: `C:\...\flutter\bin`)
- [ ] Chemin ajouté au PATH
- [ ] PowerShell redémarré
- [ ] `flutter --version` fonctionne

### Si Flutter n'est pas installé:

- [ ] Flutter téléchargé
- [ ] Flutter extrait dans `C:\src\flutter`
- [ ] Chemin `C:\src\flutter\bin` ajouté au PATH
- [ ] PowerShell redémarré
- [ ] `flutter --version` fonctionne
- [ ] `flutter doctor` exécuté pour vérifier les dépendances

## 🛠️ Après Installation - Configuration

### 1. Vérifier les dépendances

```powershell
flutter doctor
```

### 2. Installer les dépendances manquantes

Flutter doctor vous indiquera ce qui manque:
- Android Studio (pour Android)
- Visual Studio (pour Windows)
- Chrome (pour Web)

### 3. Accepter les licences Android

```powershell
flutter doctor --android-licenses
```

## 🎯 Emplacements Courants à Vérifier

Vérifier manuellement dans ces dossiers:

```
C:\src\flutter
C:\flutter
C:\Users\VotreNom\flutter
C:\Users\VotreNom\AppData\Local\flutter
C:\Program Files\flutter
C:\Program Files (x86)\flutter
C:\tools\flutter
D:\flutter
D:\src\flutter
```

## 💡 Astuce: Créer un Script de Recherche

Créer un fichier `find_flutter.ps1`:

```powershell
# find_flutter.ps1
Write-Host "Recherche de Flutter..." -ForegroundColor Cyan

$searchPaths = @(
    "C:\src\flutter",
    "C:\flutter",
    "$env:USERPROFILE\flutter",
    "$env:USERPROFILE\AppData\Local\flutter",
    "C:\Program Files\flutter",
    "C:\tools\flutter"
)

foreach ($path in $searchPaths) {
    $flutterExe = Join-Path $path "bin\flutter.exe"
    if (Test-Path $flutterExe) {
        Write-Host "✅ Trouvé: $flutterExe" -ForegroundColor Green
        Write-Host "   Chemin à ajouter au PATH: $(Join-Path $path 'bin')" -ForegroundColor Yellow
    }
}

# Recherche récursive (peut être lent)
Write-Host "`nRecherche approfondie (peut prendre du temps)..." -ForegroundColor Cyan
$found = Get-ChildItem -Path C:\Users\$env:USERNAME -Filter flutter.exe -Recurse -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 5

if ($found) {
    foreach ($file in $found) {
        Write-Host "✅ Trouvé: $($file.FullName)" -ForegroundColor Green
        $binPath = $file.DirectoryName
        Write-Host "   Chemin à ajouter au PATH: $binPath" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Flutter non trouvé. Installation nécessaire." -ForegroundColor Red
}
```

Exécuter:

```powershell
.\find_flutter.ps1
```

## 📚 Ressources

- **Installation officielle**: https://docs.flutter.dev/get-started/install/windows
- **Guide de configuration**: `docs/POWERSHELL_FLUTTER_SETUP.md`
- **Solution rapide**: `docs/QUICK_FIX_FLUTTER_POWERSHELL.md`

## 🆘 Besoin d'aide?

1. **Flutter installé mais introuvable**: Utiliser la recherche Windows ou PowerShell
2. **Flutter non installé**: Suivre le guide d'installation ci-dessus
3. **Problèmes après installation**: Exécuter `flutter doctor` pour diagnostiquer

