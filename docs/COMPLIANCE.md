# Conformité aux Normes - Campbnb Québec

**Dernière mise à jour: 2024**

## Table des matières

1. [Apple App Store](#apple-app-store)
2. [Google Play Store](#google-play-store)
3. [Stripe](#stripe)
4. [API Tierces](#api-tierces)
5. [Checklist de conformité](#checklist-de-conformité)

---

## Apple App Store

### Exigences de conformité

#### 1. Privacy Policy (Politique de confidentialité)

- **Disponible**: Politique accessible depuis l'application et le site web
- **URL**: https://campbnb.quebec/privacy
- **Mise à jour**: Dernière mise à jour documentée
- **Langues**: Disponible en français et anglais

#### 2. Data Collection (Collecte de données)

**Données collectées déclarées dans App Store Connect:**

- **Identifiants**: Email, nom, identifiant d'appareil
- **Données de contact**: Numéro de téléphone (optionnel)
- **Localisation**: Coordonnées GPS (avec consentement)
- **Données financières**: Traitées par Stripe (non stockées)
- **Données d'utilisation**: Analytics, interactions avec l'app
- **Diagnostics**: Logs d'erreurs (anonymisés)

**Finalités déclarées:**
- Fourniture des services de réservation
- Amélioration de l'application
- Communication avec les utilisateurs
- Prévention de la fraude

#### 3. App Tracking Transparency (ATT)

- **Framework ATT**: Implémenté pour iOS 14.5+
- **Demande de permission**: Affichée avant tout tracking
- **Respect du choix**: Pas de tracking si refusé
- **Alternatives**: Analytics agrégés sans identifiants

**Code d'implémentation:**
```dart
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

Future<void> requestTrackingPermission() async {
final status = await AppTrackingTransparency.requestTrackingAuthorization();
if (status == TrackingStatus.authorized) {
// Initialiser le tracking
}
}
```

#### 4. In-App Purchases

- **Stripe**: Utilisé pour les paiements (conforme aux guidelines)
- **Pas d'IAP Apple**: Les paiements ne passent pas par l'App Store
- **Transparence**: Prix clairement affichés avant paiement

#### 5. Content Guidelines

- **Contenu approprié**: Modération des listings
- **Signalement**: Système de signalement disponible
- **Respect des utilisateurs**: Code de conduite appliqué

#### 6. Technical Requirements

- **API Level**: iOS 13.0 minimum
- **Architecture**: Support 64-bit
- **Performance**: Optimisé pour les appareils récents
- **Accessibility**: Support VoiceOver et autres technologies d'assistance

---

## Google Play Store

### Exigences de conformité

#### 1. Privacy Policy (Politique de confidentialité)

- **Disponible**: Accessible depuis l'application
- **URL**: https://campbnb.quebec/privacy
- **Format**: HTML ou PDF accessible

#### 2. Data Safety (Sécurité des données)

**Données collectées et partagées:**

| Type de données | Collectées | Partagées | Finalité |
|----------------|------------|-----------|----------|
| Nom | | | Identification |
| Email | | | Compte, communication |
| Téléphone | | | Contact (optionnel) |
| Localisation | | (MapBox) | Services de carte |
| Paiements | | (Stripe) | Traitement des paiements |
| Photos | | | Profil, listings |

**Sécurité des données:**
- Chiffrement en transit (HTTPS/TLS)
- Chiffrement au repos
- Authentification forte disponible
- Contrôle d'accès basé sur les rôles

#### 3. Permissions Android

**Permissions déclarées:**

- **INTERNET**: Nécessaire pour les API
- **ACCESS_FINE_LOCATION**: Pour les services de localisation (avec consentement)
- **ACCESS_COARSE_LOCATION**: Alternative à la localisation fine
- **CAMERA**: Pour les photos de profil/listings (optionnel)
- **READ_EXTERNAL_STORAGE**: Pour sélectionner des images (Android 12-)
- **WRITE_EXTERNAL_STORAGE**: Pour sauvegarder des images (Android 12-)

**Justification des permissions:**
- Toutes les permissions sont justifiées dans le Play Console
- Demande contextuelle pour les permissions sensibles
- Explication claire de l'utilisation

#### 4. Content Rating

- **Classification**: Tout public (avec modération)
- **Contenu**: Pas de contenu inapproprié
- **Signalement**: Système de modération en place

#### 5. Target API Level

- **API Level**: 33 (Android 13) minimum
- **Compliance**: Respect des exigences Google Play
- **Mises à jour**: Maintien de la conformité

#### 6. Google Play Billing

- **Stripe**: Utilisé pour les paiements (pas de Google Play Billing)
- **Transparence**: Prix clairement affichés
- **Remboursements**: Politique claire documentée

---

## Stripe

### Conformité PCI DSS

#### 1. Niveau de conformité

- **Niveau 1 PCI DSS**: Via Stripe (nous n'acceptons pas directement les cartes)
- **Aucune donnée de carte stockée**: Tout passe par Stripe
- **Tokenisation**: Utilisation de Payment Intents

#### 2. Intégration sécurisée

**Bonnes pratiques implémentées:**

- **Stripe Elements**: Utilisation des composants sécurisés de Stripe
- **TLS 1.2+**: Toutes les communications chiffrées
- **Validation côté serveur**: Vérification de tous les paiements
- **Idempotency**: Toutes les opérations sont idempotentes

**Code d'exemple:**
```dart
// Ne jamais stocker les données de carte
// Utiliser Stripe Payment Intents
final paymentIntent = await stripe.createPaymentIntent(
amount: amount,
currency: 'cad',
paymentMethodId: paymentMethodId,
);
```

#### 3. Webhooks sécurisés

- **Signature vérifiée**: Vérification de la signature Stripe
- **HTTPS uniquement**: Endpoints webhooks en HTTPS
- **Idempotency**: Gestion des webhooks dupliqués
- **Logs**: Journalisation des événements (sans données sensibles)

**Vérification de signature:**
```typescript
// Edge Function Supabase
const sig = request.headers.get('stripe-signature');
const event = stripe.webhooks.constructEvent(
body,
sig,
process.env.STRIPE_WEBHOOK_SECRET
);
```

#### 4. 3D Secure

- **Activé**: Pour les paiements européens (SCA)
- **Support**: Authentification forte pour les cartes européennes
- **UX**: Expérience utilisateur optimisée

#### 5. Logs et monitoring

- **Pas de données sensibles**: Aucune donnée de carte dans les logs
- **Monitoring**: Surveillance des transactions suspectes
- **Alertes**: Notifications pour les échecs de paiement

---

## API Tierces

### MapBox

#### Conformité

- **Terms of Service**: Respect des conditions d'utilisation
- **Rate Limiting**: Respect des limites d'utilisation
- **Données**: Pas de stockage des données MapBox
- **Attribution**: Attribution MapBox affichée

### Google Gemini

#### Conformité

- **API Terms**: Respect des conditions d'utilisation
- **Data Usage**: Conformité aux politiques de données
- **Rate Limiting**: Respect des quotas
- **Content Policy**: Respect des politiques de contenu

### Supabase

#### Conformité

- **Data Processing Agreement**: Accord de traitement des données
- **GDPR**: Conformité RGPD
- **Security**: Certifications de sécurité
- **Backups**: Politique de sauvegarde conforme

---

## Checklist de conformité

### Pré-lancement

#### Apple App Store
- [x] Privacy Policy disponible et accessible
- [x] Data Collection déclarée dans App Store Connect
- [x] App Tracking Transparency implémenté
- [x] Content Guidelines respectées
- [x] Tests sur différents appareils iOS
- [x] Certificats et provisioning profiles valides

#### Google Play Store
- [x] Privacy Policy disponible
- [x] Data Safety complété dans Play Console
- [x] Permissions justifiées
- [x] Content Rating défini
- [x] Target API Level conforme
- [x] Tests sur différents appareils Android

#### Stripe
- [x] Compte Stripe activé et vérifié
- [x] Webhooks configurés et testés
- [x] 3D Secure activé
- [x] Tests de paiement effectués
- [x] Monitoring configuré

### Post-lancement

#### Maintenance continue
- [ ] Révision trimestrielle des politiques
- [ ] Mise à jour des dépendances
- [ ] Scans de sécurité réguliers
- [ ] Tests de conformité après mises à jour
- [ ] Revue des permissions utilisées
- [ ] Audit des données collectées

#### Monitoring
- [ ] Surveillance des transactions Stripe
- [ ] Monitoring des erreurs d'API
- [ ] Vérification des webhooks
- [ ] Alertes de sécurité configurées

---

## Contacts de conformité

### Apple
- **Support développeur**: developer.apple.com/contact
- **App Review**: Via App Store Connect

### Google
- **Support Play Console**: support.google.com/googleplay
- **Policy Issues**: play-policy-issues@google.com

### Stripe
- **Support**: support.stripe.com
- **Security**: security@stripe.com

### Campbnb Québec
- **Conformité**: compliance@campbnb.quebec
- **Sécurité**: security@campbnb.quebec
- **DPO**: dpo@campbnb.quebec

---

## Ressources

### Documentation officielle

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Policy](https://play.google.com/about/developer-content-policy/)
- [Stripe Security Guide](https://stripe.com/docs/security)
- [PCI DSS Requirements](https://www.pcisecuritystandards.org/)

### Outils de vérification

- **Apple**: App Store Connect, TestFlight
- **Google**: Play Console, Pre-launch Report
- **Stripe**: Dashboard, Test Mode, Webhook Testing

---

*Cette documentation est mise à jour régulièrement pour refléter les changements dans les exigences de conformité.*

