# 🚀 Solution Rapide - Flutter dans PowerShell

## ⚡ Solution en 2 Minutes

### Option 1: Script Automatique (Le Plus Simple)

**Exécuter ce script qui trouve et configure Flutter automatiquement:**

```powershell
# PowerShell (si politique configurée)
.\scripts\setup_flutter_path.ps1

# OU Batch (fonctionne toujours)
.\scripts\setup_flutter_path.bat
```

### Option 2: Ajout Manuel Rapide

**Dans PowerShell, exécuter (remplacer par VOTRE chemin Flutter):**

```powershell
# Exemple si Flutter est dans C:\src\flutter
$env:Path += ";C:\src\flutter\bin"

# Vérifier
flutter --version
```

**Si ça fonctionne**, rendre permanent:
1. `Win + R` → `sysdm.cpl`
2. **Advanced** → **Environment Variables**
3. **Path** → **Edit** → **New**
4. Ajouter: `C:\src\flutter\bin`
5. **OK** partout
6. **Redémarrer PowerShell**

## 📍 Où trouver Flutter?

Flutter est généralement installé dans un de ces emplacements:

- `C:\src\flutter`
- `C:\flutter`
- `C:\Users\VotreNom\flutter`
- `C:\Program Files\flutter`

**Important**: Le PATH doit pointer vers le dossier `bin` à l'intérieur!

Exemple: Si Flutter est dans `C:\src\flutter`, ajouter `C:\src\flutter\bin` au PATH.

## ✅ Vérification

Après configuration, tester:

```powershell
flutter --version
dart --version
flutter doctor
```

## 📚 Documentation Complète

- **Guide rapide**: `docs/QUICK_FIX_FLUTTER_POWERSHELL.md`
- **Guide complet**: `docs/POWERSHELL_FLUTTER_SETUP.md`
- **Problème de politique**: `docs/POWERSHELL_EXECUTION_POLICY.md`

## 🆘 Besoin d'aide?

1. Exécuter: `.\scripts\setup_flutter_path.bat`
2. Le script vous guidera étape par étape
3. Suivre les instructions à l'écran

