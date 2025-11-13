# Sécurité - Campbnb Québec

## Table des matières

1. [Authentification forte](#authentification-forte)
2. [Chiffrement des données](#chiffrement-des-données)
3. [Audit de sécurité](#audit-de-sécurité)
4. [Gestion des rôles et permissions](#gestion-des-rôles-et-permissions)
5. [Conformité RGPD](#conformité-rgpd)
6. [Conformité aux normes](#conformité-aux-normes)
7. [Plan de remédiation](#plan-de-remédiation)

---

## Authentification forte

### Authentification multi-facteurs (MFA/2FA)

L'application implémente l'authentification à deux facteurs via Supabase Auth:

- **Méthodes supportées**:
- TOTP (Time-based One-Time Password) via applications d'authentification
- SMS (optionnel, pour les utilisateurs sans smartphone)
- Email (backup)

- **Activation**:
- Obligatoire pour les hôtes
- Recommandée pour tous les utilisateurs
- Peut être activée dans les paramètres de sécurité

### Politique de mots de passe

- **Exigences minimales**:
- Minimum 12 caractères
- Au moins une majuscule
- Au moins une minuscule
- Au moins un chiffre
- Au moins un caractère spécial

- **Sécurité**:
- Hashage avec bcrypt (via Supabase)
- Vérification contre les bases de données de mots de passe compromis (Have I Been Pwned)
- Expiration des sessions après 30 jours d'inactivité
- Limitation des tentatives de connexion (5 tentatives, puis verrouillage temporaire)

### Gestion des sessions

- **JWT Tokens**:
- Durée de vie: 1 heure
- Refresh tokens: 30 jours
- Rotation automatique des tokens
- Révocation possible depuis n'importe quel appareil

- **Sécurité des sessions**:
- Validation de l'IP et de l'User-Agent
- Détection des connexions suspectes
- Notification par email lors de nouvelles connexions

---

## Chiffrement des données

### Données en transit

- **HTTPS/TLS 1.3** obligatoire pour toutes les communications
- Certificats SSL/TLS valides et à jour
- HSTS (HTTP Strict Transport Security) activé
- Pinning de certificats pour les applications mobiles

### Données au repos

- **Base de données**:
- Chiffrement au repos activé (Supabase)
- Chiffrement des colonnes sensibles (pgcrypto)
- Backups chiffrés

- **Stockage d'images**:
- Chiffrement S3-compatible (Supabase Storage)
- URLs signées avec expiration
- Accès contrôlé par RLS

- **Données sensibles**:
- Numéros de téléphone: chiffrés avec AES-256
- Adresses complètes: chiffrées pour les utilisateurs non-hôtes
- Informations de paiement: jamais stockées (Stripe gère tout)

### Chiffrement côté client

- **Flutter Secure Storage** pour les tokens et données sensibles
- Chiffrement des données locales avec AES-256
- Pas de stockage de mots de passe en clair

---

## Audit de sécurité

### Outils d'audit automatisés

#### OWASP Top 10

- **Injection**: Validation stricte des entrées, requêtes paramétrées
- **Authentification défaillante**: MFA, gestion robuste des sessions
- **Exposition de données sensibles**: Chiffrement, RLS, masquage
- **XML External Entities (XXE)**: Désactivé, validation stricte
- **Contrôle d'accès défaillant**: RLS, vérification des permissions
- **Configuration de sécurité incorrecte**: Configuration sécurisée par défaut
- **XSS**: Sanitization, CSP headers
- **Désérialisation non sécurisée**: Validation stricte
- **Composants avec vulnérabilités connues**: Mise à jour régulière
- **Journalisation et monitoring insuffisants**: Logging complet, monitoring

#### Android/iOS

- **Android**:
- ProGuard/R8 activé pour l'obfuscation
- Vérification de l'intégrité de l'APK
- Protection contre le reverse engineering
- Network Security Config pour HTTPS uniquement

- **iOS**:
- App Transport Security (ATS) activé
- Keychain pour le stockage sécurisé
- Code signing et validation
- Protection contre le jailbreak

### Scans de sécurité

- **Dépendances**: `flutter pub audit` (équivalent npm audit)
- **Code**: Analyse statique avec SonarQube
- **APK/IPA**: Scan avec MobSF (Mobile Security Framework)
- **API**: Tests de pénétration réguliers

---

## Gestion des rôles et permissions

### Rôles disponibles

1. **guest**: Utilisateur standard
- Créer des réservations
- Laisser des avis
- Envoyer des messages

2. **host**: Hôte vérifié
- Toutes les permissions guest
- Créer/modifier/supprimer des listings
- Gérer les réservations
- Répondre aux avis

3. **admin**: Administrateur
- Toutes les permissions
- Gestion des utilisateurs
- Modération de contenu
- Accès aux logs et métriques

4. **moderator**: Modérateur
- Modération de contenu
- Gestion des signalements
- Suspension d'utilisateurs

### Système de permissions

- **Row Level Security (RLS)**: Politiques granulaires par table
- **Edge Functions**: Vérification des permissions côté serveur
- **Client**: Vérification pour l'UI, mais validation serveur obligatoire

---

## Conformité RGPD

### Droits des utilisateurs

1. **Droit d'accès**: Les utilisateurs peuvent consulter toutes leurs données
2. **Droit de rectification**: Modification des données personnelles
3. **Droit à l'effacement**: Suppression complète des données
4. **Droit à la portabilité**: Export des données en JSON
5. **Droit d'opposition**: Refus du traitement de certaines données
6. **Droit à la limitation**: Limitation du traitement

### Consentement

- **Cookies**: Bannière de consentement (si web)
- **Données personnelles**: Consentement explicite lors de l'inscription
- **Marketing**: Opt-in séparé
- **Tracking**: Consentement pour analytics

### Traitement des données

- **Minimisation**: Collecte uniquement des données nécessaires
- **Finalité**: Traitement uniquement pour les finalités déclarées
- **Conservation**: Suppression après période de rétention
- **Sécurité**: Mesures techniques et organisationnelles

### DPO (Data Protection Officer)

- Contact: dpo@campbnb.quebec
- Délai de réponse: 30 jours maximum

---

## Conformité aux normes

### Apple App Store

- **Privacy Policy**: Disponible et accessible
- **Data Collection**: Déclaration complète dans App Store Connect
- **App Tracking Transparency**: Demande de permission pour le tracking
- **In-App Purchases**: Conformité aux guidelines
- **Content Guidelines**: Respect des règles de contenu

### Google Play Store

- **Privacy Policy**: Disponible et accessible
- **Data Safety**: Déclaration complète dans Play Console
- **Permissions**: Demande minimale et justifiée
- **Content Rating**: Classification appropriée
- **Target API Level**: Conformité aux exigences récentes

### Stripe

- **PCI DSS**: Conformité via Stripe (niveau 1)
- **Webhooks**: Signature vérifiée
- **Idempotency**: Toutes les opérations sont idempotentes
- **Logs**: Pas de données de carte dans les logs
- **3D Secure**: Activé pour les paiements européens

### API tierces

- **MapBox**: Conformité aux termes d'utilisation
- **Google Gemini**: Respect des politiques de données
- **Supabase**: Conformité aux accords de traitement des données

---

## Plan de remédiation

### Gestion des incidents de sécurité

#### Classification des incidents

1. **Critique**: Fuite de données, accès non autorisé
2. **Élevé**: Vulnérabilité exploitable, déni de service
3. **Moyen**: Vulnérabilité nécessitant une action
4. **Faible**: Amélioration de sécurité

#### Processus de réponse

1. **Détection**: Monitoring, alertes, signalements
2. **Containment**: Isolation de la menace
3. **Éradication**: Suppression de la cause
4. **Récupération**: Retour à la normale
5. **Post-mortem**: Analyse et amélioration

#### Communication

- **Interne**: Équipe technique immédiatement
- **Utilisateurs**: Notification si données affectées (RGPD)
- **Autorités**: CNIL si nécessaire (72h pour RGPD)
- **Public**: Communication transparente si nécessaire

### Correction des vulnérabilités

- **Délais**:
- Critique: 24 heures
- Élevé: 7 jours
- Moyen: 30 jours
- Faible: 90 jours

- **Processus**:
1. Identification et priorisation
2. Développement du correctif
3. Tests de sécurité
4. Déploiement
5. Vérification

---

## Monitoring et alertes

### Métriques surveillées

- Tentatives de connexion échouées
- Requêtes suspectes
- Modifications de données sensibles
- Erreurs d'authentification
- Accès aux endpoints admin

### Alertes

- Email pour les incidents critiques
- Slack pour l'équipe technique
- Dashboard de sécurité en temps réel

---

## Formation et sensibilisation

- Formation de l'équipe sur les bonnes pratiques
- Documentation accessible
- Revue de code avec focus sécurité
- Tests de sécurité réguliers

---

## Contact sécurité

- **Email**: security@campbnb.quebec
- **Responsable de la sécurité**: CISO
- **Signalement de vulnérabilités**: security@campbnb.quebec

---

*Dernière mise à jour: 2024*


