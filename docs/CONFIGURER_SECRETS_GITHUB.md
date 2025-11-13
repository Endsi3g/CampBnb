# 🔐 Guide : Configurer les Secrets GitHub

Ce guide vous explique comment configurer tous les secrets GitHub nécessaires pour les workflows CI/CD.

## 📍 Accès aux Secrets

1. Allez sur votre repository : https://github.com/Endsi3g/CampBnb
2. Cliquez sur **Settings** (en haut du repository)
3. Dans le menu de gauche, cliquez sur **Secrets and variables** > **Actions**
4. Cliquez sur **New repository secret**

## 🔑 Secrets Obligatoires

### 1. SUPABASE_URL

**Description** : URL de votre projet Supabase

**Où le trouver** :
- Dashboard Supabase > Settings > API
- Format : `https://xxxxx.supabase.co`

**Exemple** :
```
https://kniaisdkzeflauawmyka.supabase.co
```

**Nom du secret** : `SUPABASE_URL`

---

### 2. SUPABASE_ANON_KEY

**Description** : Clé anonyme (publique) de Supabase

**Où le trouver** :
- Dashboard Supabase > Settings > API > Project API keys
- Clé `anon` `public`

**Exemple** :
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuaWFpc2RremVmbGF1YXdteWthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNDk2NzMsImV4cCI6MjA3ODYyNTY3M30.HL5ZhIZS7abfeuHnPW54KN8qQgsoXohfYwJhO0Tgyoo
```

**Nom du secret** : `SUPABASE_ANON_KEY`

---

### 3. SUPABASE_ACCESS_TOKEN

**Description** : Token d'accès pour l'API Supabase (pour les déploiements)

**Où le trouver** :
- Dashboard Supabase > Account Settings > Access Tokens
- Ou via CLI : `supabase projects list` (nécessite `supabase login`)

**Comment créer** :
```bash
# Installer Supabase CLI
npm install -g supabase

# Se connecter
supabase login

# Le token sera dans ~/.supabase/access-token
```

**Nom du secret** : `SUPABASE_ACCESS_TOKEN`

---

### 4. SUPABASE_PROJECT_REF

**Description** : Référence/ID du projet Supabase

**Où le trouver** :
- Dashboard Supabase > Settings > General
- C'est la partie de l'URL : `https://[PROJECT_REF].supabase.co`

**Exemple** :
```
kniaisdkzeflauawmyka
```

**Nom du secret** : `SUPABASE_PROJECT_REF`

**Note** : Certains workflows utilisent `SUPABASE_PROJECT_ID` au lieu de `SUPABASE_PROJECT_REF`. Utilisez le même nom que dans vos workflows.

---

### 5. GOOGLE_MAPS_API_KEY

**Description** : Clé API Google Maps

**Où le trouver** :
- Google Cloud Console > APIs & Services > Credentials
- Créez une clé API et activez "Maps SDK for Android" et "Maps SDK for iOS"

**Nom du secret** : `GOOGLE_MAPS_API_KEY`

---

### 6. GEMINI_API_KEY

**Description** : Clé API Google Gemini

**Où le trouver** :
- Google AI Studio : https://makersuite.google.com/app/apikey
- Ou Google Cloud Console > APIs & Services > Credentials

**Nom du secret** : `GEMINI_API_KEY`

---

## 🔧 Secrets Optionnels

### NETLIFY_AUTH_TOKEN

**Description** : Token d'authentification Netlify (si vous déployez sur Netlify)

**Où le trouver** :
- Netlify Dashboard > User settings > Applications > New access token

**Nom du secret** : `NETLIFY_AUTH_TOKEN`

---

### NETLIFY_SITE_ID

**Description** : ID du site Netlify

**Où le trouver** :
- Netlify Dashboard > Site settings > General > Site details

**Nom du secret** : `NETLIFY_SITE_ID`

---

### MAPBOX_ACCESS_TOKEN

**Description** : Token d'accès Mapbox (si vous utilisez Mapbox au lieu de Google Maps)

**Où le trouver** :
- Mapbox Account > Access tokens

**Nom du secret** : `MAPBOX_ACCESS_TOKEN`

---

### STITCH_API_KEY

**Description** : Clé API Google Stitch (pour la synchronisation automatique des screens)

**Où le trouver** :
- Google Stitch Dashboard (si disponible)

**Nom du secret** : `STITCH_API_KEY`

---

### SLACK_WEBHOOK_URL

**Description** : Webhook Slack pour les notifications de déploiement

**Où le trouver** :
- Slack > Apps > Incoming Webhooks > Add to Slack

**Format** :
```
https://hooks.slack.com/services/WORKSPACE_ID/CHANNEL_ID/WEBHOOK_TOKEN
```

**Note** : Remplacez WORKSPACE_ID, CHANNEL_ID et WEBHOOK_TOKEN par vos valeurs réelles depuis Slack.

**Nom du secret** : `SLACK_WEBHOOK_URL`

---

## ✅ Checklist de Configuration

- [ ] `SUPABASE_URL` configuré
- [ ] `SUPABASE_ANON_KEY` configuré
- [ ] `SUPABASE_ACCESS_TOKEN` configuré
- [ ] `SUPABASE_PROJECT_REF` configuré
- [ ] `GOOGLE_MAPS_API_KEY` configuré
- [ ] `GEMINI_API_KEY` configuré
- [ ] `NETLIFY_AUTH_TOKEN` configuré (si applicable)
- [ ] `NETLIFY_SITE_ID` configuré (si applicable)
- [ ] `MAPBOX_ACCESS_TOKEN` configuré (si applicable)
- [ ] `STITCH_API_KEY` configuré (si applicable)
- [ ] `SLACK_WEBHOOK_URL` configuré (si applicable)

## 🔒 Sécurité

- ⚠️ **Ne jamais** commiter les secrets dans le code
- ⚠️ **Ne jamais** partager les secrets publiquement
- ✅ Utilisez toujours les GitHub Secrets pour les valeurs sensibles
- ✅ Vérifiez régulièrement que les secrets sont à jour

## 🧪 Tester les Secrets

Après avoir configuré les secrets, testez-les en :

1. Créant une branche test
2. Faisant un commit
3. Créant une Pull Request
4. Vérifiant que les workflows CI/CD s'exécutent correctement

## 📚 Ressources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Supabase CLI Documentation](https://supabase.com/docs/reference/cli)
- [Google Cloud Console](https://console.cloud.google.com/)

## 🆘 Problèmes Courants

### Le workflow échoue avec "Secret not found"

- Vérifiez que le nom du secret correspond exactement (sensible à la casse)
- Vérifiez que le secret est configuré dans le bon repository

### Le workflow échoue avec "Authentication failed"

- Vérifiez que les tokens/keys sont valides et non expirés
- Régénérez les tokens si nécessaire

### Les secrets ne sont pas disponibles dans les workflows

- Vérifiez que les secrets sont configurés dans **Settings > Secrets and variables > Actions**
- Vérifiez que les workflows utilisent la syntaxe correcte : `${{ secrets.SECRET_NAME }}`

