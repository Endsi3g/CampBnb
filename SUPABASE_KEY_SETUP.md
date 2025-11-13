# 🔑 Configuration de la Clé Supabase

## ✅ Support des Variables d'Environnement

L'application supporte **deux noms de variables** pour la clé Supabase :

1. **`SUPABASE_KEY`** (recommandé, compatible avec votre code JavaScript)
2. **`SUPABASE_ANON_KEY`** (alternative standard)

## 📝 Configuration du fichier `.env`

Créez un fichier `.env` à la racine du projet avec **une** de ces options :

### Option 1 : SUPABASE_KEY (Recommandé)

```env
SUPABASE_KEY=votre_cle_publishable_ici
```

### Option 2 : SUPABASE_ANON_KEY

```env
SUPABASE_ANON_KEY=votre_cle_publishable_ici
```

## 🔍 Comment ça fonctionne

Le code Flutter vérifie d'abord `SUPABASE_KEY`, puis `SUPABASE_ANON_KEY` :

```dart
// Dans lib/core/config/app_config.dart
static String get supabaseAnonKey => 
    dotenv.env['SUPABASE_KEY'] ??           // Priorité 1
    dotenv.env['SUPABASE_ANON_KEY'] ??      // Priorité 2
    '';
```

## 🎯 Compatibilité avec votre code JavaScript

Votre code JavaScript utilise :
```javascript
const supabaseKey = process.env.SUPABASE_KEY
```

Pour rester cohérent, utilisez **`SUPABASE_KEY`** dans votre fichier `.env` Flutter.

## 📋 Exemple complet de `.env`

```env
# Supabase (utilisez SUPABASE_KEY ou SUPABASE_ANON_KEY)
SUPABASE_KEY=votre_cle_publishable_ici

# MapBox (déjà configuré avec valeur par défaut)
MAPBOX_ACCESS_TOKEN=pk.eyJ1IjoiY2FtcGJuYiIsImEiOiJjbWh3N21wZjAwNDhuMm9weXFwMmt1c2VqIn0.r6bKsNWgKmIb0FzWOcZh8g

# Gemini (optionnel)
GEMINI_API_KEY=votre_cle_gemini

# Stripe (optionnel)
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## ✅ Vérification

Après avoir créé le fichier `.env`, lancez l'application :

```bash
flutter run
```

Vous devriez voir :
```
✅ Supabase initialisé avec succès
```

## 🔐 Où trouver votre clé Supabase

1. Allez sur : https://supabase.com/dashboard/project/kniaisdkzeflauawmyka/settings/api
2. Pour **mobile/desktop** : Copiez la **Publishable Key**
3. Pour **web** : Copiez l'**anon key**

## 📚 Documentation

- Guide complet : `CONFIGURATION_SUPABASE.md`
- Démarrage rapide : `QUICK_START_SUPABASE.md`

---

**Configuration prête ! 🎉**

