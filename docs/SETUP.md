# Guide de Configuration Initiale - Campbnb Québec

Ce guide vous aidera à configurer le repository GitHub pour Campbnb Québec.

## Checklist de Configuration

### 1. Repository GitHub

- [ ] Créer le repository sur GitHub
- [ ] Configurer la description et les topics
- [ ] Activer les GitHub Pages (si nécessaire)
- [ ] Configurer les branch protection rules

### 2. Secrets GitHub

Configurer les secrets dans **Settings > Secrets and variables > Actions**:

#### Secrets Requis

- [ ] `SUPABASE_URL` - URL du projet Supabase
- [ ] `SUPABASE_ANON_KEY` - Clé anonyme Supabase
- [ ] `SUPABASE_ACCESS_TOKEN` - Token d'accès Supabase
- [ ] `SUPABASE_DB_PASSWORD` - Mot de passe de la base de données
- [ ] `SUPABASE_PROJECT_ID` - ID du projet Supabase
- [ ] `GOOGLE_MAPS_API_KEY` - Clé API Google Maps
- [ ] `GEMINI_API_KEY` - Clé API Gemini

#### Secrets Optionnels

- [ ] `NETLIFY_AUTH_TOKEN` - Token Netlify (si déploiement web)
- [ ] `NETLIFY_SITE_ID` - ID du site Netlify
- [ ] `STITCH_API_KEY` - Clé API Google Stitch
- [ ] `SLACK_WEBHOOK_URL` - Webhook Slack pour notifications

### 3. Branch Protection

Configurer dans **Settings > Branches**:

#### Branche `main`

- [ ] Require a pull request before merging
- [ ] Require approvals (1 minimum)
- [ ] Require status checks to pass before merging
- [ ] CI - Build & Tests
- [ ] Lint & Format
- [ ] Security Scan
- [ ] Require branches to be up to date before merging
- [ ] Do not allow bypassing the above settings

#### Branche `develop`

- [ ] Require a pull request before merging
- [ ] Require approvals (1 minimum)
- [ ] Require status checks to pass before merging
- [ ] Allow force pushes (uniquement pour mainteneurs)

### 4. Labels GitHub

Exécuter le script pour configurer les labels:

```bash
chmod +x scripts/setup_labels.sh
./scripts/setup_labels.sh
```

Ou configurer manuellement depuis `.github/labels.json`

### 5. GitHub Actions

- [ ] Vérifier que les workflows sont activés
- [ ] Tester le workflow CI sur une branche test
- [ ] Configurer les notifications (Slack, email)

### 6. Dependabot

- [ ] Vérifier que Dependabot est activé (`.github/dependabot.yml`)
- [ ] Configurer les notifications pour les mises à jour

### 7. Security

- [ ] Activer GitHub Advanced Security (si disponible)
- [ ] Configurer Code Scanning
- [ ] Configurer Secret Scanning
- [ ] Vérifier les permissions des actions

### 8. Wiki (Optionnel)

- [ ] Activer le Wiki du repository
- [ ] Créer la page d'accueil du Wiki
- [ ] Documenter les processus internes

### 9. Projects (Optionnel)

- [ ] Créer un projet GitHub pour le suivi
- [ ] Configurer les colonnes (To Do, In Progress, Done)
- [ ] Lier les issues et PRs

### 10. Documentation

- [x] Vérifier que tous les liens dans le README fonctionnent
- [x] Mettre à jour les URLs dans les fichiers de documentation
- [x] Remplacer `VOTRE_ORG` par le nom réel de l'organisation

## Configuration Détaillée

### URLs Configurées

- `Endsi3g` → Organisation GitHub
- `CampBnb` → Nom du repository

### Fichiers à Modifier

1. **README.md**: Badges et liens
2. **docs/README.md**: Liens vers les issues
3. **.github/SECURITY.md**: Email de contact
4. **LICENSE**: Email de contact

### Configuration des Workflows

Vérifier que les workflows sont correctement configurés:

1. `.github/workflows/ci.yml` - Build et tests
2. `.github/workflows/deploy.yml` - Déploiement
3. `.github/workflows/lint.yml` - Lint et format
4. `.github/workflows/security.yml` - Security scan
5. `.github/workflows/sync-stitch-screens.yml` - Sync screens
6. `.github/workflows/pr-checks.yml` - PR validation

## Vérification Finale

### Test des Workflows

1. Créer une branche test
2. Faire un commit
3. Créer une PR
4. Vérifier que tous les checks passent

### Test de Synchronisation Stitch

```bash
python scripts/sync_stitch_screens.py
```

### Test des Templates

1. Créer une issue avec le template bug
2. Créer une issue avec le template feature
3. Créer une PR et vérifier le template

## Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)

## 🆘 Support

Si vous rencontrez des problèmes:

1. Consultez la [documentation](../README.md)
2. Ouvrez une [issue](https://github.com/Endsi3g/CampBnb/issues)
3. Contactez l'équipe de développement


