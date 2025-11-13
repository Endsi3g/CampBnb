# 🔄 Guide de Migration vers le Monorepo

Ce guide explique comment migrer le code existant vers la nouvelle structure monorepo.

## 📋 Vue d'ensemble

La migration consiste à :
1. Déplacer le code de `lib/` vers `packages/shared/lib/`
2. Déplacer les assets vers `packages/shared/assets/`
3. Mettre à jour les imports dans le code
4. Configurer les applications mobile et web

## 🚀 Étapes de Migration

### 1. Déplacer le Code Partagé

```bash
# Créer la structure du package shared
mkdir -p packages/shared/lib

# Déplacer le code
cp -r lib/core packages/shared/lib/
cp -r lib/features packages/shared/lib/
cp -r lib/shared packages/shared/lib/
```

### 2. Déplacer les Assets

```bash
# Déplacer les assets
cp -r assets packages/shared/
```

### 3. Mettre à Jour les Imports

Tous les imports dans `packages/shared/lib/` doivent utiliser des chemins relatifs à `lib/` :

```dart
// Avant (dans lib/)
import 'core/config/app_config.dart';
import 'features/auth/presentation/screens/login_screen.dart';

// Après (dans packages/shared/lib/)
// Les imports restent les mêmes car ils sont relatifs à lib/
import 'core/config/app_config.dart';
import 'features/auth/presentation/screens/login_screen.dart';
```

### 4. Mettre à Jour les Applications Mobile et Web

Les applications mobile et web doivent importer depuis le package shared :

```dart
// Dans packages/mobile/lib/main.dart ou packages/web/lib/main.dart
import 'package:campbnb_shared/core/config/app_config.dart';
import 'package:campbnb_shared/features/auth/presentation/screens/login_screen.dart';
```

### 5. Mettre à Jour pubspec.yaml

Le `pubspec.yaml` du package shared doit contenir toutes les dépendances communes.

Les `pubspec.yaml` de mobile et web doivent référencer le package shared :

```yaml
dependencies:
  campbnb_shared:
    path: ../shared
```

## 📝 Checklist de Migration

- [ ] Code déplacé vers `packages/shared/lib/`
- [ ] Assets déplacés vers `packages/shared/assets/`
- [ ] Imports mis à jour dans le package shared
- [ ] Applications mobile et web créées
- [ ] Imports mis à jour dans mobile/web
- [ ] `pubspec.yaml` configurés correctement
- [ ] Tests mis à jour et fonctionnels
- [ ] Build mobile fonctionnel
- [ ] Build web fonctionnel

## 🔧 Scripts de Migration

### Script Automatique (Bash)

```bash
#!/bin/bash
# scripts/migrate_to_monorepo.sh

echo "🚀 Migration vers le monorepo..."

# Créer la structure
mkdir -p packages/shared/lib
mkdir -p packages/shared/assets

# Déplacer le code
echo "📦 Déplacement du code..."
cp -r lib/core packages/shared/lib/
cp -r lib/features packages/shared/lib/
cp -r lib/shared packages/shared/lib/

# Déplacer les assets
echo "🎨 Déplacement des assets..."
cp -r assets packages/shared/

echo "✅ Migration terminée!"
echo "📝 N'oubliez pas de :"
echo "   1. Mettre à jour les imports dans packages/shared/lib/"
echo "   2. Configurer les pubspec.yaml"
echo "   3. Tester les applications"
```

### Script PowerShell (Windows)

```powershell
# scripts/migrate_to_monorepo.ps1

Write-Host "🚀 Migration vers le monorepo..." -ForegroundColor Green

# Créer la structure
New-Item -ItemType Directory -Force -Path "packages/shared/lib"
New-Item -ItemType Directory -Force -Path "packages/shared/assets"

# Déplacer le code
Write-Host "📦 Déplacement du code..." -ForegroundColor Yellow
Copy-Item -Path "lib/core" -Destination "packages/shared/lib/" -Recurse -Force
Copy-Item -Path "lib/features" -Destination "packages/shared/lib/" -Recurse -Force
Copy-Item -Path "lib/shared" -Destination "packages/shared/lib/" -Recurse -Force

# Déplacer les assets
Write-Host "🎨 Déplacement des assets..." -ForegroundColor Yellow
Copy-Item -Path "assets" -Destination "packages/shared/" -Recurse -Force

Write-Host "✅ Migration terminée!" -ForegroundColor Green
Write-Host "📝 N'oubliez pas de :" -ForegroundColor Cyan
Write-Host "   1. Mettre à jour les imports dans packages/shared/lib/"
Write-Host "   2. Configurer les pubspec.yaml"
Write-Host "   3. Tester les applications"
```

## ⚠️ Points d'Attention

1. **Imports** : Vérifier que tous les imports fonctionnent correctement
2. **Assets** : S'assurer que les chemins vers les assets sont corrects
3. **Tests** : Mettre à jour les chemins dans les tests
4. **Configuration** : Vérifier les fichiers de configuration (Android, iOS, Web)

## 🆘 Dépannage

### Erreur : Package not found

```bash
# Vérifier que le package shared est bien référencé
cd packages/mobile
flutter pub get
```

### Erreur : Asset not found

Vérifier que les assets sont bien dans `packages/shared/assets/` et que le `pubspec.yaml` du package shared les référence.

### Erreur : Import error

Vérifier que les imports utilisent `package:campbnb_shared/...` dans mobile/web.

## 📚 Ressources

- [Guide du Monorepo](MONOREPO_GUIDE.md)
- [Documentation Flutter Packages](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)

