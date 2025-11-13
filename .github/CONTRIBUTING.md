# Guide de Contribution - Campbnb Québec

Merci de votre intérêt pour contribuer à Campbnb Québec ! Ce document décrit les processus et conventions pour contribuer au projet.

## 📋 Table des matières

- [Code de Conduite](#code-de-conduite)
- [Processus de Contribution](#processus-de-contribution)
- [Conventions Git](#conventions-git)
- [Standards de Code](#standards-de-code)
- [Tests](#tests)
- [Documentation](#documentation)
- [Pull Requests](#pull-requests)

## 📜 Code de Conduite

En participant à ce projet, vous acceptez de respecter notre [Code de Conduite](CODE_OF_CONDUCT.md). Nous nous engageons à fournir un environnement accueillant et respectueux pour tous.

## 🚀 Processus de Contribution

### 1. Fork et Clone

```bash
# Fork le repository sur GitHub, puis clonez votre fork
git clone https://github.com/VOTRE_USERNAME/campbnb-quebec.git
cd campbnb-quebec
```

### 2. Configuration de l'environnement

```bash
# Installer les dépendances
flutter pub get

# Générer les fichiers de code
flutter pub run build_runner build --delete-conflicting-outputs

# Vérifier que tout fonctionne
flutter analyze
flutter test
```

### 3. Créer une branche

Suivez notre [convention de nommage des branches](#conventions-git) :

```bash
git checkout -b feature/ma-nouvelle-feature
# ou
git checkout -b bugfix/correction-bug
```

### 4. Développer

- Écrivez du code propre et bien commenté
- Suivez les [standards de code](#standards-de-code)
- Ajoutez des tests pour vos changements
- Mettez à jour la documentation si nécessaire

### 5. Commit

Suivez nos [conventions de commit](#conventions-git) :

```bash
git add .
git commit -m "feat: ajouter filtre recherche par prix"
```

### 6. Push et Pull Request

```bash
git push origin feature/ma-nouvelle-feature
```

Puis créez une Pull Request sur GitHub en suivant le [template PR](.github/pull_request_template.md).

## 🔀 Conventions Git

### Workflow Git

Nous utilisons un **Git Flow simplifié** :

- `main` : Branche de production (toujours stable)
- `develop` : Branche de développement (intégration des features)
- `feature/*` : Nouvelles fonctionnalités
- `bugfix/*` : Corrections de bugs
- `hotfix/*` : Corrections urgentes pour production
- `release/*` : Préparation de releases

### Nommage des branches

Format : `<type>/<description-courte>`

Types disponibles :
- `feature/` : Nouvelle fonctionnalité
- `bugfix/` : Correction de bug
- `hotfix/` : Correction urgente
- `refactor/` : Refactoring
- `docs/` : Documentation uniquement
- `test/` : Tests uniquement
- `chore/` : Tâches de maintenance

Exemples :
- `feature/search-filters`
- `bugfix/reservation-crash`
- `hotfix/payment-gateway`

### Conventions de Commit

Nous suivons les [Conventional Commits](https://www.conventionalcommits.org/) :

Format : `<type>(<scope>): <description>`

#### Types

- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation
- `style` : Formatage (pas de changement de code)
- `refactor` : Refactoring
- `perf` : Amélioration de performance
- `test` : Ajout/modification de tests
- `chore` : Tâches de maintenance
- `ci` : Changements CI/CD
- `build` : Système de build

#### Scope (optionnel)

- `auth` : Authentification
- `reservation` : Réservations
- `search` : Recherche
- `ui` : Interface utilisateur
- `api` : API/Backend
- `config` : Configuration

#### Exemples

```bash
feat(search): ajouter filtre par prix
fix(reservation): corriger crash lors de la validation
docs(readme): mettre à jour instructions installation
refactor(auth): simplifier logique de connexion
perf(map): optimiser rendu des markers
test(reservation): ajouter tests unitaires
chore(deps): mettre à jour dépendances
```

#### Corps du commit (optionnel)

Pour les commits complexes, ajoutez un corps :

```bash
feat(reservation): ajouter système de notifications

- Envoi de notification lors de confirmation
- Notification de rappel 24h avant
- Gestion des préférences utilisateur
```

## 📐 Standards de Code

### Dart/Flutter

- Suivez les [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Utilisez `flutter analyze` et `dart format` avant chaque commit
- Respectez les règles définies dans `analysis_options.yaml`

### Architecture

- Suivez l'architecture **domain-driven** du projet
- Chaque feature doit être autonome dans `lib/features/`
- Utilisez Riverpod pour la gestion d'état
- Séparation claire : domain / data / presentation

### Nommage

- **Fichiers** : `snake_case.dart`
- **Classes** : `PascalCase`
- **Variables/Fonctions** : `camelCase`
- **Constantes** : `SCREAMING_SNAKE_CASE`

### Commentaires

- Commentez les fonctions complexes
- Utilisez la documentation Dart (`///`)
- Expliquez le "pourquoi", pas le "quoi"

## 🧪 Tests

### Types de tests

1. **Tests unitaires** : Fonctions, services, providers
2. **Tests d'intégration** : Flux complets
3. **Tests widget** : Composants UI

### Exécution

```bash
# Tous les tests
flutter test

# Tests avec couverture
flutter test --coverage

# Tests spécifiques
flutter test test/features/reservation/reservation_test.dart
```

### Exigences

- **Couverture minimale** : 70% pour le code critique
- **Tous les tests doivent passer** avant une PR
- Ajoutez des tests pour les nouvelles features

## 📚 Documentation

### Code

- Documentez les fonctions publiques avec `///`
- Ajoutez des exemples pour les APIs complexes
- Maintenez les docstrings à jour

### Markdown

- Mettez à jour le README si nécessaire
- Documentez les nouvelles features dans `docs/`
- Ajoutez des diagrammes si pertinent

## 🔍 Pull Requests

### Avant de créer une PR

- [ ] Votre code suit les conventions
- [ ] Tous les tests passent
- [ ] Le code est formaté (`dart format`)
- [ ] Aucun warning d'analyse
- [ ] La documentation est à jour
- [ ] Vous avez testé manuellement

### Processus de Review

1. **Auto-review** : Vérifiez votre propre code
2. **CI Checks** : Attendez que les checks CI passent
3. **Review** : Au moins 1 approbation requise
4. **Merge** : Squash and merge (sauf exceptions)

### Critères d'approbation

- Code conforme aux standards
- Tests passent et couverture suffisante
- Pas de régression
- Documentation à jour
- Pas de conflits

## 🐛 Signaler un Bug

Utilisez le [template de bug report](.github/ISSUE_TEMPLATE/bug_report.yml) et incluez :

- Description claire du problème
- Étapes pour reproduire
- Comportement attendu vs actuel
- Version, plateforme, appareil
- Logs/erreurs pertinents
- Captures d'écran si applicable

## 💡 Proposer une Feature

Utilisez le [template de feature request](.github/ISSUE_TEMPLATE/feature_request.yml) et incluez :

- Problème/besoin à résoudre
- Solution proposée
- Alternatives considérées
- Priorité et catégorie
- Mockups si disponibles

## ❓ Questions ?

- Ouvrez une issue avec le label `question`
- Consultez la [documentation](docs/)
- Contactez les mainteneurs

Merci de contribuer à Campbnb Québec ! 🎉


