# 📝 Commandes Git pour CampBnb

## 🚀 Commandes Exactes pour le Premier Push

Copiez-collez ces commandes dans votre terminal :

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

## ⚠️ AVANT d'exécuter ces commandes

1. **Créez le repository sur GitHub** :
   - Allez sur https://github.com/new
   - Propriétaire : `Endsi3g`
   - Nom : `CampBnb`
   - Description : "Plateforme de réservation de campings au Québec"
   - **NE PAS** cocher : README, .gitignore, license
   - Cliquez sur "Create repository"

## 🔄 Si le Repository Existe Déjà avec un README

Si vous avez créé le repository avec un README :

```bash
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/Endsi3g/CampBnb.git
git pull origin main --allow-unrelated-histories
git push -u origin main
```

## ✅ Vérification

Après le push, vérifiez :
- Repository : https://github.com/Endsi3g/CampBnb
- Tous les fichiers sont présents
- Workflows visibles dans l'onglet "Actions"

## 📚 Documentation

- [Guide Complet du Premier Commit](FIRST_COMMIT.md)
- [Setup GitHub](docs/SETUP.md)
- [Infrastructure Prête](GITHUB_READY.md)

