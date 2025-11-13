# 🔧 Configuration Supabase - Campbnb Québec

## 📋 Configuration Requise

### 1. Créer le fichier `.env`

Créez un fichier `.env` à la racine du projet Flutter avec le contenu suivant :

```env
# Supabase
SUPABASE_URL=https://kniaisdkzeflauawmyka.supabase.co
# Vous pouvez utiliser SUPABASE_KEY ou SUPABASE_ANON_KEY (les deux sont supportés)
SUPABASE_KEY=votre_cle_publishable_ici
# OU
# SUPABASE_ANON_KEY=votre_cle_anon_ou_publishable_ici

# MapBox
MAPBOX_ACCESS_TOKEN=pk.ey...

# Google Gemini
GEMINI_API_KEY=your-gemini-api-key

# Stripe (optionnel)
STRIPE_PUBLISHABLE_KEY=pk_test_...

# Sentry (optionnel)
SENTRY_DSN=https://...
```

### 2. Obtenir la clé Supabase

#### Pour Mobile/Desktop (Recommandé)

1. Allez dans votre projet Supabase : https://supabase.com/dashboard/project/kniaisdkzeflauawmyka
2. Allez dans **Settings > API**
3. Copiez la **Publishable Key** (pas l'anon key)
4. Collez-la dans `.env` comme `SUPABASE_KEY` ou `SUPABASE_ANON_KEY`

**Note:** Pour les applications mobiles et desktop, Supabase recommande d'utiliser la clé publishable plutôt que l'anon key pour une meilleure sécurité.

#### Pour Web

1. Allez dans **Settings > API**
2. Copiez l'**anon key**
3. Collez-la dans `.env`

### 3. Vérifier la Configuration

L'application initialise Supabase automatiquement au démarrage dans `lib/main.dart` :

```dart
await Supabase.initialize(
  url: 'https://kniaisdkzeflauawmyka.supabase.co',
  anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  debug: AppConfig.isDevelopment,
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
);
```

## ✅ Vérification

### Tester la connexion

1. Lancez l'application :
   ```bash
   flutter run
   ```

2. Vérifiez les logs dans la console :
   - ✅ `Supabase initialisé avec succès` = Connexion réussie
   - ❌ `ERREUR: Échec de l'initialisation Supabase` = Problème de configuration

### Tester l'authentification

```dart
// Exemple dans votre code
try {
  final response = await SupabaseService.signUp(
    email: 'test@example.com',
    password: 'password123',
    data: {
      'first_name': 'Jean',
      'last_name': 'Dupont',
    },
  );
  print('Inscription réussie: ${response.user?.email}');
} catch (e) {
  print('Erreur: $e');
}
```

## 🔐 Sécurité

### Bonnes Pratiques

1. **Ne jamais commiter le fichier `.env`** (déjà dans `.gitignore`)
2. **Utiliser la clé publishable pour mobile/desktop**
3. **Utiliser l'anon key pour web uniquement**
4. **Activer RLS (Row Level Security)** sur toutes les tables Supabase
5. **Valider toutes les entrées utilisateur** côté serveur

### Variables d'environnement par plateforme

#### Android
- Les variables `.env` sont chargées automatiquement
- Pour la production, utilisez des secrets sécurisés

#### iOS
- Les variables `.env` sont chargées automatiquement
- Pour la production, utilisez des secrets sécurisés

#### Web
- Les variables `.env` sont chargées automatiquement
- ⚠️ **Attention**: Les variables sont exposées dans le code JavaScript
- Utilisez des Edge Functions pour les opérations sensibles

#### Windows/Desktop
- Les variables `.env` sont chargées automatiquement
- Utilisez la clé publishable

## 🐛 Dépannage

### Erreur : "Supabase not initialized"

**Cause:** Le fichier `.env` n'existe pas ou la clé est manquante.

**Solution:**
1. Créez le fichier `.env` à la racine du projet
2. Ajoutez `SUPABASE_KEY=votre_cle` ou `SUPABASE_ANON_KEY=votre_cle`
3. Redémarrez l'application

### Erreur : "Invalid API key"

**Cause:** La clé API est incorrecte ou expirée.

**Solution:**
1. Vérifiez la clé dans Supabase Dashboard
2. Copiez la bonne clé (publishable pour mobile/desktop)
3. Mettez à jour `.env`

### Erreur : "Network error"

**Cause:** Problème de connexion ou URL incorrecte.

**Solution:**
1. Vérifiez votre connexion internet
2. Vérifiez que l'URL est correcte : `https://kniaisdkzeflauawmyka.supabase.co`
3. Vérifiez que le projet Supabase est actif

## 📚 Ressources

- [Documentation Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Guide d'authentification](https://supabase.com/docs/guides/auth)
- [Sécurité RLS](https://supabase.com/docs/guides/auth/row-level-security)

---

**Configuration terminée ! 🎉**

