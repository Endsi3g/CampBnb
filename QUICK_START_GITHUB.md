# ⚡ Quick Start : Configuration GitHub

Guide rapide pour configurer votre repository GitHub en 3 étapes.

## 🎯 3 Étapes Essentielles

### 1️⃣ Configurer les Secrets GitHub (10 min)

**Accès** : https://github.com/Endsi3g/CampBnb/settings/secrets/actions

**Secrets à ajouter** :
- `SUPABASE_URL` - URL Supabase
- `SUPABASE_ANON_KEY` - Clé anonyme Supabase
- `SUPABASE_ACCESS_TOKEN` - Token d'accès
- `SUPABASE_PROJECT_REF` - ID du projet
- `GOOGLE_MAPS_API_KEY` - Clé Google Maps
- `GEMINI_API_KEY` - Clé Gemini

**Guide détaillé** : [docs/CONFIGURER_SECRETS_GITHUB.md](docs/CONFIGURER_SECRETS_GITHUB.md)

---

### 2️⃣ Configurer les Branch Protection (5 min)

**Accès** : https://github.com/Endsi3g/CampBnb/settings/branches

**Pour `main`** :
- ✅ Require pull request
- ✅ Require 1 approval
- ✅ Require status checks (CI, Lint, Security)
- ✅ Do not allow bypassing

**Guide détaillé** : [docs/CONFIGURER_BRANCH_PROTECTION.md](docs/CONFIGURER_BRANCH_PROTECTION.md)

---

### 3️⃣ Configurer les Labels (2 min)

**Option A : Script Automatique**

```powershell
# Windows
.\scripts\setup_labels_powershell.ps1

# Linux/Mac
chmod +x scripts/setup_labels.sh
./scripts/setup_labels.sh
```

**Option B : Manuel**

Allez sur https://github.com/Endsi3g/CampBnb/labels et créez les labels depuis `.github/labels.json`

**Guide détaillé** : [docs/CONFIGURER_LABELS_GITHUB.md](docs/CONFIGURER_LABELS_GITHUB.md)

---

## ✅ Vérification

1. Créez une branche test
2. Faites un commit
3. Créez une PR
4. Vérifiez que les workflows CI/CD s'exécutent

## 📚 Documentation Complète

- [Guide de Configuration Complet](docs/GUIDE_CONFIGURATION_COMPLETE.md)
- [Index de Configuration](docs/INDEX_CONFIGURATION.md)

## 🆘 Besoin d'Aide ?

Consultez les guides détaillés dans le dossier `docs/` ou ouvrez une [issue](https://github.com/Endsi3g/CampBnb/issues).

