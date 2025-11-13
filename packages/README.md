# 📦 Packages Campbnb Québec

Ce répertoire contient les packages de l'application Campbnb Québec organisés en monorepo.

## 📋 Structure

```
packages/
├── shared/          # Package partagé (core, features, shared)
├── mobile/          # Application mobile (iOS & Android)
└── web/             # Application web (Flutter Web)
```

## 🚀 Démarrage Rapide

### Installation globale

```bash
# À la racine du projet
flutter pub get

# Installer les dépendances de chaque package
cd packages/shared && flutter pub get
cd ../mobile && flutter pub get
cd ../web && flutter pub get
```

### Développement

#### Application Mobile

```bash
cd packages/mobile
flutter run
```

#### Application Web

```bash
cd packages/web
flutter run -d chrome
```

## 📦 Packages

### `shared/`

Package Dart contenant tout le code partagé entre mobile et web :
- Core (configuration, routing, thème)
- Features (toutes les fonctionnalités métier)
- Shared (modèles, services, widgets)

Voir [README.md](shared/README.md) pour plus de détails.

### `mobile/`

Application Flutter pour iOS et Android.

Voir [README.md](mobile/README.md) pour plus de détails.

### `web/`

Application Flutter Web.

Voir [README.md](web/README.md) pour plus de détails.

## 🔧 Workflow de Développement

1. **Modifier le code partagé** : Éditer les fichiers dans `packages/shared/`
2. **Tester localement** : Lancer l'application mobile ou web
3. **Build** : Utiliser les scripts de build dans chaque package
4. **Déployer** : Suivre les instructions de déploiement de chaque package

## 📝 Notes

- Tous les packages partagent le même code via `campbnb_shared`
- Les dépendances spécifiques à une plateforme sont dans les packages respectifs
- Les assets sont partagés depuis `packages/shared/assets/`

