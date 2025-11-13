# Solution Rapide - Flutter non reconnu dans PowerShell

## 🚨 Problème

```
flutter : Le terme «flutter» n'est pas reconnu comme nom d'applet de commande
```

## ✅ Solution Immédiate (5 minutes)

### Étape 1: Trouver où Flutter est installé

**Option A: Si Flutter est déjà installé**

1. Ouvrir **File Explorer** (Explorateur de fichiers)
2. Chercher dans ces emplacements courants:
   - `C:\src\flutter`
   - `C:\flutter`
   - `C:\Users\VotreNom\flutter`
   - `C:\Program Files\flutter`
   - `C:\tools\flutter`

**Option B: Si Flutter n'est pas installé**

Télécharger Flutter depuis: https://docs.flutter.dev/get-started/install/windows

### Étape 2: Trouver le chemin exact

Une fois trouvé, noter le chemin complet, par exemple:
- `C:\src\flutter\bin` ← **Important: doit pointer vers le dossier `bin`**

### Étape 3: Ajouter au PATH (Solution Rapide)

**Méthode 1: Temporaire (Session actuelle)**

Dans PowerShell, exécuter (remplacer par VOTRE chemin):

```powershell
$env:Path += ";C:\src\flutter\bin"
```

Puis vérifier:

```powershell
flutter --version
```

**Méthode 2: Permanent (Recommandé)**

1. Appuyer sur `Win + R`
2. Taper `sysdm.cpl` et appuyer sur Entrée
3. Cliquer sur l'onglet **Advanced** (Avancé)
4. Cliquer sur **Environment Variables** (Variables d'environnement)
5. Dans **System variables** (Variables système), trouver `Path`
6. Cliquer sur **Edit** (Modifier)
7. Cliquer sur **New** (Nouveau)
8. Ajouter: `C:\src\flutter\bin` (remplacer par votre chemin)
9. Cliquer sur **OK** partout
10. **Fermer et rouvrir PowerShell**

### Étape 4: Vérifier

Dans un **nouveau PowerShell**:

```powershell
flutter --version
dart --version
flutter doctor
```

## 🔧 Solutions Alternatives

### Solution A: Utiliser le chemin complet

Si vous ne voulez pas modifier le PATH:

```powershell
# Remplacer par votre chemin
C:\src\flutter\bin\flutter.exe --version
```

### Solution B: Créer un alias PowerShell

Dans PowerShell, exécuter:

```powershell
# Remplacer par votre chemin
Set-Alias -Name flutter -Value "C:\src\flutter\bin\flutter.exe"
Set-Alias -Name dart -Value "C:\src\flutter\bin\dart.exe"
```

### Solution C: Utiliser Git Bash ou WSL

Si PowerShell pose problème:
- Installer **Git for Windows** (inclut Git Bash)
- Ou installer **WSL** (Windows Subsystem for Linux)

## 📋 Checklist Rapide

- [ ] Flutter est installé sur le système
- [ ] Le chemin vers `flutter\bin` est connu
- [ ] Le chemin est ajouté au PATH (temporaire ou permanent)
- [ ] PowerShell est redémarré (si modification permanente)
- [ ] `flutter --version` fonctionne

## 🧪 Test Rapide

Exécuter ces commandes dans PowerShell:

```powershell
# Test 1: Vérifier Flutter
flutter --version

# Test 2: Vérifier Dart
dart --version

# Test 3: Vérifier la configuration
flutter doctor
```

## ❓ Dépannage

### "Flutter toujours non reconnu"

1. Vérifier que le chemin est correct (doit pointer vers `bin`)
2. Vérifier avec: `$env:Path -split ';'` dans PowerShell
3. Redémarrer PowerShell complètement
4. Vérifier les permissions d'accès au dossier

### "Accès refusé"

1. Vérifier que vous avez les droits d'administration
2. Vérifier les permissions du dossier Flutter
3. Essayer de déplacer Flutter dans un dossier accessible

### "Chemin introuvable"

1. Vérifier que Flutter est bien installé
2. Vérifier l'orthographe du chemin
3. Utiliser des guillemets si le chemin contient des espaces: `"C:\Program Files\flutter\bin"`

## 🎯 Solution Définitive

Pour une solution permanente, suivre ces étapes:

1. **Installer Flutter** (si pas déjà fait)
   - Télécharger depuis: https://docs.flutter.dev/get-started/install/windows
   - Extraire dans `C:\src\flutter` (ou autre emplacement)

2. **Ajouter au PATH système**
   - `Win + R` → `sysdm.cpl`
   - Variables d'environnement → Path → Nouveau
   - Ajouter: `C:\src\flutter\bin`

3. **Redémarrer PowerShell**

4. **Vérifier**
   ```powershell
   flutter --version
   flutter doctor
   ```

## 📚 Documentation Complète

Pour plus de détails, voir:
- `docs/POWERSHELL_FLUTTER_SETUP.md` - Guide complet
- `docs/POWERSHELL_EXECUTION_POLICY.md` - Problèmes de politique

## 💡 Astuce

Pour éviter de retaper le chemin à chaque fois, créer un fichier `setup_flutter.ps1`:

```powershell
# setup_flutter.ps1
$env:Path += ";C:\src\flutter\bin"
Write-Host "Flutter ajouté au PATH pour cette session"
flutter --version
```

Puis exécuter au début de chaque session:

```powershell
. .\setup_flutter.ps1
```

