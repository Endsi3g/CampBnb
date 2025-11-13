# 📦 Campbnb Shared Package

Package partagé contenant le code commun entre l'application mobile et l'application web de Campbnb Québec.

## 📋 Contenu

Ce package contient :

- **Core** : Configuration, routing, thème, services de base
- **Features** : Toutes les fonctionnalités métier (auth, listing, reservation, etc.)
- **Shared** : Modèles, services et widgets partagés

## 🚀 Utilisation

### Dans l'application mobile

```yaml
dependencies:
  campbnb_shared:
    path: ../shared
```

### Dans l'application web

```yaml
dependencies:
  campbnb_shared:
    path: ../shared
```

## 📁 Structure

```
lib/
├── core/              # Configuration, services partagés, monitoring
├── features/          # Features métier (DDD)
│   ├── domain/        # Entités, repositories, use cases
│   ├── data/          # Datasources, models, repositories impl
│   └── presentation/  # Screens, widgets, providers
└── shared/            # Composants, services, modèles partagés
```

## 🔧 Développement

```bash
# Installer les dépendances
flutter pub get

# Générer les fichiers de code
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer les tests
flutter test
```

## 📝 Notes

- Ce package est utilisé par les applications mobile et web
- Tous les imports doivent être relatifs à `lib/`
- Les dépendances spécifiques à une plateforme doivent être dans les packages mobile/web

