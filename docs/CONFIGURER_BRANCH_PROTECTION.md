# 🛡️ Guide : Configurer les Branch Protection Rules

Ce guide vous explique comment configurer les règles de protection des branches pour sécuriser votre repository.

## 📍 Accès aux Branch Protection Rules

1. Allez sur votre repository : https://github.com/Endsi3g/CampBnb
2. Cliquez sur **Settings** (en haut du repository)
3. Dans le menu de gauche, cliquez sur **Branches**
4. Cliquez sur **Add rule** ou modifiez une règle existante

## 🌿 Configuration pour la Branche `main`

### Étape 1 : Nom de la Branche

Dans le champ **Branch name pattern**, entrez :
```
main
```

### Étape 2 : Protection de Base

Cochez les options suivantes :

#### ✅ Require a pull request before merging

- **Require approvals** : `1` (minimum)
- **Dismiss stale pull request approvals when new commits are pushed** : ✅ Coché
- **Require review from Code Owners** : ⬜ (optionnel)

#### ✅ Require status checks to pass before merging

Cochez les checks suivants :
- ✅ `CI - Build & Tests` (ou `CI`)
- ✅ `Lint & Format` (ou `lint`)
- ✅ `Security Scan` (ou `security-scan`)

**Important** : Les noms exacts des checks dépendent de vos workflows. Vérifiez dans l'onglet "Actions" après un premier run.

#### ✅ Require branches to be up to date before merging

Cochez cette option pour forcer la synchronisation avant le merge.

#### ✅ Require conversation resolution before merging

Cochez cette option pour s'assurer que tous les commentaires sont résolus.

#### ✅ Require signed commits

⬜ Optionnel - Requiert des commits signés (nécessite GPG)

#### ✅ Require linear history

⬜ Optionnel - Force un historique linéaire (pas de merge commits)

#### ✅ Include administrators

✅ **COCHÉ** - Applique les règles même aux administrateurs

#### ✅ Do not allow bypassing the above settings

✅ **COCHÉ** - Empêche le contournement des règles

### Étape 3 : Restrictions

#### ✅ Restrict who can push to matching branches

- Laissez vide pour permettre à tous les collaborateurs avec accès d'écriture
- Ou ajoutez des équipes spécifiques

#### ✅ Allow force pushes

❌ **DÉCOCHÉ** - Ne pas autoriser les force pushes sur `main`

#### ✅ Allow deletions

❌ **DÉCOCHÉ** - Ne pas autoriser la suppression de la branche `main`

### Étape 4 : Sauvegarder

Cliquez sur **Create** ou **Save changes**

---

## 🌿 Configuration pour la Branche `develop`

### Étape 1 : Nom de la Branche

```
develop
```

### Étape 2 : Protection (Moins Stricte)

#### ✅ Require a pull request before merging

- **Require approvals** : `1` (minimum)

#### ✅ Require status checks to pass before merging

- ✅ `CI - Build & Tests`
- ✅ `Lint & Format`

#### ✅ Require branches to be up to date before merging

✅ Coché

#### ✅ Include administrators

✅ Coché

#### ⚠️ Allow force pushes

✅ **COCHÉ** - Autoriser les force pushes (uniquement pour les mainteneurs)

**Note** : Cette option permet aux mainteneurs de rebaser facilement, mais doit être utilisée avec précaution.

### Étape 3 : Sauvegarder

Cliquez sur **Create** ou **Save changes**

---

## 📋 Checklist de Configuration

### Branche `main`

- [ ] Règle créée pour `main`
- [ ] Pull request requis avant merge
- [ ] 1 approbation minimum requise
- [ ] Status checks requis : CI, Lint, Security
- [ ] Branches à jour requises
- [ ] Administrateurs inclus
- [ ] Force push désactivé
- [ ] Suppression désactivée
- [ ] Bypass désactivé

### Branche `develop`

- [ ] Règle créée pour `develop`
- [ ] Pull request requis avant merge
- [ ] 1 approbation minimum requise
- [ ] Status checks requis : CI, Lint
- [ ] Branches à jour requises
- [ ] Administrateurs inclus
- [ ] Force push activé (pour mainteneurs uniquement)

## 🧪 Tester les Branch Protection Rules

1. Créez une branche test :
   ```bash
   git checkout -b test/branch-protection
   ```

2. Faites un commit :
   ```bash
   echo "test" >> test.txt
   git add test.txt
   git commit -m "test: vérification branch protection"
   git push origin test/branch-protection
   ```

3. Créez une Pull Request vers `main`

4. Vérifiez que :
   - ✅ La PR ne peut pas être mergée sans approbation
   - ✅ Les status checks doivent passer
   - ✅ Vous ne pouvez pas push directement sur `main`

## 🔧 Configuration Avancée

### Code Owners

Créez un fichier `.github/CODEOWNERS` pour définir les propriétaires de code :

```
# Propriétaires par défaut
* @Endsi3g

# Backend
/supabase/ @backend-team

# Frontend
/lib/ @frontend-team

# Documentation
/docs/ @docs-team
```

### Required Status Checks

Les noms exacts des checks sont définis dans vos workflows. Exemples :

- `CI - Build & Tests` (défini dans `.github/workflows/ci.yml`)
- `Lint & Format` (défini dans `.github/workflows/lint.yml`)
- `Security Scan` (défini dans `.github/workflows/security.yml`)

Pour trouver les noms exacts :
1. Allez dans l'onglet "Actions"
2. Exécutez un workflow
3. Regardez les noms des jobs dans le workflow

## 📚 Ressources

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [Code Owners Documentation](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)

## 🆘 Problèmes Courants

### Les status checks ne s'affichent pas

- Attendez que les workflows s'exécutent au moins une fois
- Vérifiez que les workflows sont activés dans Settings > Actions > General

### Impossible de merger une PR

- Vérifiez que tous les status checks sont passés (✅ verts)
- Vérifiez qu'au moins 1 approbation a été donnée
- Vérifiez que la branche est à jour avec `main`

### Force push bloqué

- C'est normal sur `main` - utilisez une branche feature
- Sur `develop`, seuls les mainteneurs peuvent force push

