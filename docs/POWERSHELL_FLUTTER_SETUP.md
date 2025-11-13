# Configuration Flutter/Dart dans PowerShell (Windows)

## Problème

Les commandes `flutter` et `dart` ne sont pas reconnues dans PowerShell.

## Solution 1: Ajouter Flutter au PATH (Recommandé)

### Étape 1: Trouver le chemin Flutter

1. Ouvrir **File Explorer**
2. Naviguer vers le dossier où Flutter est installé (ex: `C:\src\flutter`)
3. Copier le chemin complet

### Étape 2: Ajouter au PATH système

1. Appuyer sur `Win + R`
2. Taper `sysdm.cpl` et appuyer sur Entrée
3. Aller dans l'onglet **Advanced**
4. Cliquer sur **Environment Variables**
5. Dans **System variables**, trouver `Path`
6. Cliquer sur **Edit**
7. Cliquer sur **New**
8. Ajouter le chemin Flutter (ex: `C:\src\flutter\bin`)
9. Cliquer sur **OK** pour fermer toutes les fenêtres
10. **Redémarrer PowerShell** (fermer et rouvrir)

### Étape 3: Vérifier

Ouvrir un nouveau PowerShell et taper:

```powershell
flutter --version
dart --version
```

## Solution 2: Ajouter au PATH de session PowerShell

Si vous ne voulez pas modifier le PATH système:

```powershell
# Remplacer par votre chemin Flutter
$env:Path += ";C:\src\flutter\bin"

# Vérifier
flutter --version
```

**Note**: Cette modification est temporaire et sera perdue à la fermeture de PowerShell.

## Solution 3: Créer un alias PowerShell

Ajouter dans votre profil PowerShell (`$PROFILE`):

```powershell
# Trouver le profil
$PROFILE

# Éditer le profil (créer s'il n'existe pas)
notepad $PROFILE

# Ajouter ces lignes (remplacer par votre chemin)
$env:Path += ";C:\src\flutter\bin"
```

## Solution 4: Utiliser Flutter depuis le dossier d'installation

Si Flutter est installé mais pas dans le PATH:

```powershell
# Aller dans le dossier Flutter
cd C:\src\flutter\bin

# Exécuter les commandes
.\flutter --version
.\dart --version
```

## Vérification Complète

Après configuration, vérifier:

```powershell
# Version Flutter
flutter --version

# Version Dart
dart --version

# Doctor Flutter
flutter doctor

# Tests
flutter test test/monitoring/error_capture_test.dart
```

## Alternative: Utiliser Git Bash ou WSL

Si PowerShell pose problème:

1. **Git Bash**: Installer Git for Windows et utiliser Git Bash
2. **WSL**: Installer Windows Subsystem for Linux et utiliser le terminal Linux

## Dépannage

### Flutter toujours non reconnu après ajout au PATH

1. Vérifier que le chemin est correct
2. Redémarrer PowerShell complètement
3. Vérifier avec `$env:Path` dans PowerShell

### Erreur "flutter: command not found"

1. Vérifier que Flutter est bien installé
2. Vérifier que le chemin `flutter\bin` existe
3. Vérifier les permissions d'accès

## Commandes Utiles

```powershell
# Voir le PATH actuel
$env:Path -split ';'

# Ajouter temporairement au PATH
$env:Path += ";C:\src\flutter\bin"

# Vérifier si Flutter est accessible
Get-Command flutter -ErrorAction SilentlyContinue
```

## Problème de Politique d'Exécution PowerShell

Si vous obtenez l'erreur "l'exécution de scripts est désactivée", voir:
- `docs/POWERSHELL_EXECUTION_POLICY.md` pour la résolution complète
- Ou utiliser le script Batch: `scripts/test_sentry.bat`

## Ressources

- [Documentation Flutter Windows](https://docs.flutter.dev/get-started/install/windows)
- [Configuration PATH Windows](https://www.computerhope.com/issues/ch000549.htm)
- [Politique d'exécution PowerShell](./POWERSHELL_EXECUTION_POLICY.md)

