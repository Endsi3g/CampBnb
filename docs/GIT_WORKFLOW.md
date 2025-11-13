# Git Workflow - Campbnb Québec

Ce document décrit le workflow Git utilisé dans le projet Campbnb Québec.

## Structure des Branches

### Branches principales

- **`main`**: Branche de production
- Toujours stable et déployable
- Protégée (merge uniquement via PR)
- Chaque commit sur `main` déclenche un déploiement

- **`develop`**: Branche de développement
- Intégration des nouvelles features
- Branche de base pour les features
- Tests d'intégration continus

### Branches de support

- **`feature/*`**: Nouvelles fonctionnalités
- Branche depuis `develop`
- Merge dans `develop` via PR
- Exemple: `feature/search-filters`

- **`bugfix/*`**: Corrections de bugs
- Branche depuis `develop` (ou `main` si critique)
- Merge dans `develop` (ou `main` si hotfix)
- Exemple: `bugfix/reservation-crash`

- **`hotfix/*`**: Corrections urgentes pour production
- Branche depuis `main`
- Merge dans `main` ET `develop`
- Exemple: `hotfix/payment-gateway`

- **`release/*`**: Préparation de releases
- Branche depuis `develop`
- Merge dans `main` et `develop`
- Exemple: `release/v1.1.0`

## Workflow de Développement

### 1. Feature Development

```bash
# 1. S'assurer que develop est à jour
git checkout develop
git pull origin develop

# 2. Créer une branche feature
git checkout -b feature/ma-feature

# 3. Développer et commiter
git add .
git commit -m "feat: ajouter nouvelle feature"

# 4. Pousser la branche
git push origin feature/ma-feature

# 5. Créer une Pull Request vers develop
```

### 2. Bug Fix

```bash
# 1. S'assurer que develop est à jour
git checkout develop
git pull origin develop

# 2. Créer une branche bugfix
git checkout -b bugfix/correction-bug

# 3. Corriger et commiter
git add .
git commit -m "fix: corriger bug de réservation"

# 4. Pousser et créer PR vers develop
git push origin bugfix/correction-bug
```

### 3. Hotfix (Production)

```bash
# 1. Créer branche depuis main
git checkout main
git pull origin main
git checkout -b hotfix/correction-urgente

# 2. Corriger
git add .
git commit -m "fix: correction urgente paiement"

# 3. Pousser
git push origin hotfix/correction-urgente

# 4. Créer PR vers main
# Après merge dans main, merger aussi dans develop
```

### 4. Release

```bash
# 1. Créer branche release depuis develop
git checkout develop
git pull origin develop
git checkout -b release/v1.1.0

# 2. Préparer la release (version, changelog, etc.)
# 3. Tester
# 4. Créer PR vers main et develop
```

## Conventions de Commit

Voir [CONTRIBUTING.md](../.github/CONTRIBUTING.md#conventions-git) pour les détails.

Format: `<type>(<scope>): <description>`

## Merge Strategy

### Pull Requests vers `develop`

- **Squash and Merge**: Recommandé pour les features
- **Merge Commit**: Pour les branches complexes avec plusieurs commits importants
- **Rebase and Merge**: Éviter (garde l'historique linéaire mais peut être problématique)

### Pull Requests vers `main`

- **Squash and Merge**: Standard
- Toujours via PR, jamais de push direct

## ️ Protection des Branches

### `main`

- Protection activée
- Require pull request reviews (1 approbation minimum)
- Require status checks to pass (CI)
- Require branches to be up to date
- No force push
- No deletion

### `develop`

- Protection activée
- Require pull request reviews (1 approbation minimum)
- Require status checks to pass (CI)
- ️ Allow force push (uniquement pour les mainteneurs)

## Synchronisation

### Mettre à jour votre branche feature

```bash
# Depuis votre branche feature
git checkout feature/ma-feature
git fetch origin
git rebase origin/develop
# ou
git merge origin/develop
```

### Résoudre les conflits

```bash
# 1. Mettre à jour develop
git checkout develop
git pull origin develop

# 2. Rebaser votre feature
git checkout feature/ma-feature
git rebase develop

# 3. Résoudre les conflits
# Éditer les fichiers en conflit
git add .
git rebase --continue

# 4. Force push (si nécessaire)
git push origin feature/ma-feature --force-with-lease
```

## Checklist avant Merge

- [ ] Tous les tests passent
- [ ] Code review approuvé
- [ ] Pas de conflits
- [ ] Documentation à jour
- [ ] Changelog mis à jour (si applicable)
- [ ] Version mise à jour (si release)

## À éviter

- Push direct sur `main` ou `develop`
- Force push sur les branches partagées
- Merge sans PR
- Commits directement sur `main`/`develop`
- Branches feature trop longues (max 2-3 semaines)

## Ressources

- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)


