# 🚀 Démarrage Rapide - Connexion Supabase

## ✅ Configuration Rapide

### 1. Créer le fichier `.env`

**Option rapide** : Copiez le fichier `.env.example` :
```bash
# Windows PowerShell
Copy-Item .env.example .env

# Linux/Mac
cp .env.example .env
```

**Ou créez manuellement** un fichier `.env` à la racine :

```env
# Supabase (clé déjà configurée dans .env.example)
SUPABASE_URL=https://kniaisdkzeflauawmyka.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuaWFpc2RremVmbGF1YXdteWthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNDk2NzMsImV4cCI6MjA3ODYyNTY3M30.HL5ZhIZS7abfeuHnPW54KN8qQgsoXohfYwJhO0Tgyoo
```

### 2. Obtenir la clé Supabase

1. Allez sur : https://supabase.com/dashboard/project/kniaisdkzeflauawmyka/settings/api
2. Copiez la **Publishable Key** (pour mobile/desktop)
3. Collez-la dans votre fichier `.env`

### 3. Lancer l'application

```bash
flutter pub get
flutter run
```

## ✅ Vérification

Si vous voyez dans les logs :
```
✅ Supabase initialisé avec succès
```

**C'est bon !** L'application est connectée à Supabase.

## 📝 Notes

- L'URL Supabase est déjà configurée dans le code : `https://kniaisdkzeflauawmyka.supabase.co`
- Vous devez seulement ajouter la clé dans `.env` comme `SUPABASE_KEY` ou `SUPABASE_ANON_KEY`
- Pour mobile/desktop, utilisez la **Publishable Key** (plus sécurisée)
- Le fichier `.env` est déjà dans `.gitignore` (ne sera pas commité)

## 🔗 Liens Utiles

- Dashboard Supabase : https://supabase.com/dashboard/project/kniaisdkzeflauawmyka
- Documentation : `CONFIGURATION_SUPABASE.md`

---

**Prêt à démarrer ! 🎉**

