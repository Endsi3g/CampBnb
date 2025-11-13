# 🚀 Créer votre fichier .env

## ✅ Configuration Rapide

Vos clés Supabase sont déjà configurées ! Il vous suffit de créer le fichier `.env` à la racine du projet.

### Option 1 : Utiliser le script automatique (Recommandé)

**Windows PowerShell :**
```powershell
.\scripts\create_env.ps1
```

**Linux/Mac :**
```bash
chmod +x scripts/create_env.sh
./scripts/create_env.sh
```

### Option 2 : Créer manuellement

Créez un fichier `.env` à la racine du projet avec ce contenu :

```env
# Supabase Configuration
SUPABASE_URL=https://kniaisdkzeflauawmyka.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuaWFpc2RremVmbGF1YXdteWthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNDk2NzMsImV4cCI6MjA3ODYyNTY3M30.HL5ZhIZS7abfeuHnPW54KN8qQgsoXohfYwJhO0Tgyoo

# MapBox (déjà configuré)
MAPBOX_ACCESS_TOKEN=pk.eyJ1IjoiY2FtcGJuYiIsImEiOiJjbWh3N21wZjAwNDhuMm9weXFwMmt1c2VqIn0.r6bKsNWgKmIb0FzWOcZh8g
```

## ✅ Vérification

Après avoir créé le fichier `.env`, testez la connexion :

```bash
flutter pub get
flutter run
```

Vous devriez voir dans les logs :
```
✅ Supabase initialisé avec succès
```

## 📋 Informations de Configuration

- **Project URL**: `https://kniaisdkzeflauawmyka.supabase.co`
- **Anon Key**: Déjà configurée dans `.env.example`
- **MapBox Token**: Déjà configuré dans le code

## 🔐 Sécurité

⚠️ **Important** : Le fichier `.env` est dans `.gitignore` et ne sera **jamais** commité dans Git.

- ✅ `.env` = Ignoré par Git (sécurisé)
- ✅ `.env.example` = Version template (peut être commitée)

## 🎯 Prochaines Étapes

1. ✅ Créer le fichier `.env` (voir ci-dessus)
2. ✅ Lancer l'application : `flutter run`
3. ✅ Vérifier la connexion Supabase dans les logs

---

**Configuration prête ! 🎉**

