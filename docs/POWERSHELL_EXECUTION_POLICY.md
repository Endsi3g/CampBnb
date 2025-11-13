# Résolution - Politique d'Exécution PowerShell

## Problème

```
.\scripts\test_sentry_manual.ps1 : Impossible de charger le fichier
car l'exécution de scripts est désactivée sur ce système.
```

## Solution 1: Modifier la Politique d'Exécution (Recommandé)

### Option A: Pour la Session Actuelle (Temporaire)

Ouvrir PowerShell en **Administrateur** et exécuter:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

**Note**: Cette modification est valide uniquement pour la session PowerShell actuelle.

### Option B: Pour l'Utilisateur Actuel (Permanent)

Ouvrir PowerShell en **Administrateur** et exécuter:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Note**: Cette modification est permanente pour votre utilisateur.

### Option C: Pour Tous les Utilisateurs (Permanent - Requiert Admin)

Ouvrir PowerShell en **Administrateur** et exécuter:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

**Note**: Cette modification affecte tous les utilisateurs du système.

## Solution 2: Contourner la Politique (Alternative)

### Option A: Exécuter avec Bypass

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test_sentry_manual.ps1
```

### Option B: Exécuter le Contenu Directement

Au lieu d'exécuter le script, copier-coller le contenu dans PowerShell:

```powershell
# Ouvrir le fichier et copier son contenu
Get-Content .\scripts\test_sentry_manual.ps1

# Puis coller et exécuter dans PowerShell
```

## Solution 3: Vérifier la Politique Actuelle

Pour voir la politique actuelle:

```powershell
Get-ExecutionPolicy -List
```

**Résultat attendu**:
```
        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
 CurrentUser       RemoteSigned
LocalMachine          Restricted
```

## Solution 4: Alternative - Utiliser les Commandes Directement

Au lieu d'utiliser le script, exécuter les commandes directement:

### Test 1: Vérifier Flutter

```powershell
flutter --version
```

### Test 2: Vérifier Dart

```powershell
dart --version
```

### Test 3: Exécuter les Tests

```powershell
flutter test test/monitoring/error_capture_test.dart
```

### Test 4: Lancer l'Application

```powershell
flutter run
```

## Solution 5: Créer un Fichier Batch (.bat)

Créer un fichier `test_sentry.bat` à la place:

```batch
@echo off
echo Testing Sentry Error Capture
echo.

REM Vérifier Flutter
flutter --version
if errorlevel 1 (
    echo Flutter not found
    exit /b 1
)

REM Exécuter les tests
echo Running tests...
flutter test test/monitoring/error_capture_test.dart

pause
```

Puis exécuter:

```powershell
.\test_sentry.bat
```

## Solution 6: Utiliser Git Bash ou WSL

Si PowerShell pose problème, utiliser:

1. **Git Bash**: Installer Git for Windows
2. **WSL**: Windows Subsystem for Linux

## Recommandation

**Pour un usage personnel**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Pour un usage temporaire**:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test_sentry_manual.ps1
```

## Vérification

Après avoir modifié la politique, vérifier:

```powershell
Get-ExecutionPolicy
```

**Résultat attendu**: `RemoteSigned` ou `Bypass`

## Sécurité

### Niveaux de Politique

- **Restricted**: Aucun script ne peut s'exécuter (par défaut)
- **RemoteSigned**: Scripts locaux OK, scripts téléchargés signés
- **Unrestricted**: Tous les scripts peuvent s'exécuter (non recommandé)
- **Bypass**: Aucune restriction (temporaire uniquement)

### Recommandation de Sécurité

Utiliser `RemoteSigned` pour:
- ✅ Permettre l'exécution de scripts locaux
- ✅ Protéger contre les scripts téléchargés non signés
- ✅ Équilibrer sécurité et fonctionnalité

## Dépannage

### Erreur "Access Denied"

1. Ouvrir PowerShell en **Administrateur**
2. Réessayer la commande `Set-ExecutionPolicy`

### Erreur "Cannot be loaded"

1. Vérifier que le fichier existe
2. Vérifier les permissions du fichier
3. Essayer avec le chemin complet

### La Politique se Réinitialise

1. Vérifier les politiques de groupe (GPO)
2. Vérifier les politiques d'entreprise
3. Contacter l'administrateur système

## Commandes Utiles

```powershell
# Voir toutes les politiques
Get-ExecutionPolicy -List

# Voir la politique effective
Get-ExecutionPolicy

# Modifier pour la session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Modifier pour l'utilisateur
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Bypass temporaire
powershell -ExecutionPolicy Bypass -File .\script.ps1
```

## Ressources

- [Documentation Microsoft - Execution Policies](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies)
- [Guide PowerShell Security](https://docs.microsoft.com/powershell/scripting/security/)

