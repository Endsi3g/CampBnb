# 🔐 Module Authentification - Campbnb Québec

Documentation technique du module d'authentification.

## 📋 Vue d'ensemble

Le module d'authentification gère :
- Inscription et connexion des utilisateurs
- Authentification via email, Google, Apple
- Gestion des sessions
- Vérification des comptes

## 🏗️ Architecture

### Structure

```
lib/features/auth/
├── domain/
│   └── repositories/
│       └── auth_repository.dart          # Interface du repository
├── data/
│   └── repositories/
│       └── auth_repository_impl.dart    # Implémentation Supabase
└── presentation/
    ├── providers/
    │   └── auth_provider.dart           # Riverpod providers
    └── screens/
        ├── welcome_screen.dart
        ├── login_screen.dart
        └── signup_screen.dart
```

## 🔧 Implémentation

### Repository

**Interface** : `AuthRepository`

```dart
abstract class AuthRepository {
  Future<User?> signUpWithEmail(String email, String password);
  Future<User?> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
}
```

**Implémentation** : `AuthRepositoryImpl`

Utilise `SupabaseService` pour :
- Inscription/connexion email
- Authentification OAuth (Google, Apple)
- Gestion des sessions
- Récupération du mot de passe

### Providers Riverpod

**authRepositoryProvider**
- Fournit l'instance du repository

**authNotifierProvider**
- Gère l'état d'authentification
- Écoute les changements de session

**currentUserProvider**
- Fournit l'utilisateur actuel
- Se met à jour automatiquement

## 📱 Screens

### WelcomeScreen
- Premier écran de l'application
- Options : Se connecter / S'inscrire

### LoginScreen
- Connexion par email
- Connexion via Google/Apple
- Lien "Mot de passe oublié"

### SignUpScreen
- Inscription par email
- Inscription via Google/Apple
- Validation des champs

## 🔒 Sécurité

- **Mots de passe** : Hashés via Supabase Auth
- **Sessions** : JWT tokens gérés par Supabase
- **OAuth** : Flux sécurisés pour Google/Apple
- **Validation** : Côté client et serveur

## 📚 Ressources

- [API Authentification](../api/authentication-api.md)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)

---

**Dernière mise à jour :** 2024

