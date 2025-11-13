# 🚀 Guide du Premier Commit - CampBnb

Ce guide vous aidera à créer le repository GitHub et faire le premier push.

## 📋 Prérequis

- Git installé sur votre machine
- Compte GitHub (Endsi3g)
- Accès au repository (créer sur GitHub si nécessaire)

## 🔧 Étapes d'Initialisation

### Option 1 : Script Automatique (Recommandé)

#### Sur Linux/Mac :

```bash
chmod +x scripts/init_git.sh
./scripts/init_git.sh
```

#### Sur Windows (PowerShell) :

```powershell
.\scripts\init_git.ps1
```

### Option 2 : Commandes Manuelles

```bash
# 1. Initialiser Git
git init

# 2. Ajouter tous les fichiers
git add .

# 3. Créer le premier commit
git commit -m "first commit"

# 4. Renommer la branche en main
git branch -M main

# 5. Ajouter le remote GitHub
git remote add origin https://github.com/Endsi3g/CampBnb.git

# 6. Pousser vers GitHub
git push -u origin main
```

## ⚠️ Important : Créer le Repository sur GitHub d'abord

**AVANT** d'exécuter les commandes, créez le repository sur GitHub :

1. Allez sur https://github.com/new
2. Propriétaire : `Endsi3g`
3. Nom du repository : `CampBnb`
4. Description : "Plateforme de réservation de campings au Québec"
5. Visibilité : Public ou Private (selon vos préférences)
6. **NE PAS** cocher :
   - ❌ Add a README file
   - ❌ Add .gitignore
   - ❌ Choose a license
7. Cliquez sur "Create repository"

## 🔄 Si le Repository Existe Déjà avec un README

Si vous avez créé le repository avec un README sur GitHub :

```bash
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/Endsi3g/CampBnb.git
git pull origin main --allow-unrelated-histories
# Résoudre les conflits si nécessaire
git push -u origin main
```

## ✅ Vérification Post-Push

Après le push réussi, vérifiez :

1. ✅ Repository accessible : https://github.com/Endsi3g/CampBnb
2. ✅ Tous les fichiers présents
3. ✅ Structure `.github/` visible
4. ✅ Workflows GitHub Actions visibles dans l'onglet "Actions"

## 🔐 Configuration Post-Push

Après le premier push, configurez :

1. **Secrets GitHub** (voir `docs/SETUP.md`)
   - Allez sur Settings > Secrets and variables > Actions
   - Ajoutez tous les secrets requis

2. **Branch Protection Rules** (voir `docs/SETUP.md`)
   - Allez sur Settings > Branches
   - Configurez les règles pour `main`

3. **Labels GitHub**
   ```bash
   chmod +x scripts/setup_labels.sh
   ./scripts/setup_labels.sh
   ```

## 📚 Documentation

- [Guide de Setup Complet](docs/SETUP.md)
- [Git Workflow](docs/GIT_WORKFLOW.md)
- [Documentation Complète](docs/README.md)

## 🆘 Problèmes Courants

### Erreur : "remote origin already exists"

```bash
git remote remove origin
git remote add origin https://github.com/Endsi3g/CampBnb.git
```

### Erreur : "failed to push some refs"

Le repository GitHub a peut-être un README. Utilisez :

```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### Erreur : "authentication failed"

Configurez vos credentials Git :

```bash
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

Ou utilisez un Personal Access Token pour l'authentification.

## 🎉 C'est Prêt !

Une fois le push réussi, votre infrastructure GitHub est en place et prête à être utilisée !

