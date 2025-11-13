# Politique de Sécurité

## 🔒 Versions Supportées

Nous fournissons des mises à jour de sécurité pour les versions suivantes :

| Version | Supportée          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## 🚨 Signaler une Vulnérabilité

Si vous découvrez une vulnérabilité de sécurité, **NE PAS** ouvrir une issue publique.

### Processus de Signalement

1. **Email** : Envoyez un email à [security@campbnb-quebec.com] (remplacer par l'email réel)
2. **Détails** : Incluez :
   - Description de la vulnérabilité
   - Étapes pour reproduire
   - Impact potentiel
   - Suggestions de correction (si applicable)

### Réponse

- Nous répondrons dans les **48 heures**
- Nous vous tiendrons informé de la progression
- Nous publierons un correctif dès que possible
- Nous vous créditerons dans les notes de version (si vous le souhaitez)

## 🔐 Bonnes Pratiques de Sécurité

### Pour les Contributeurs

- Ne jamais commiter de secrets ou clés API
- Utiliser les variables d'environnement pour les configurations sensibles
- Vérifier les dépendances pour les vulnérabilités connues
- Suivre les principes de sécurité dans le code

### Checklist de Sécurité

Avant chaque PR :

- [ ] Aucun secret dans le code
- [ ] Validation des entrées utilisateur
- [ ] Protection contre les injections (SQL, XSS)
- [ ] Authentification et autorisation vérifiées
- [ ] HTTPS utilisé pour toutes les communications
- [ ] Données sensibles chiffrées

## 🛡️ Mesures de Sécurité Actuelles

- ✅ Authentification JWT via Supabase
- ✅ Row Level Security (RLS) sur la base de données
- ✅ Validation côté client et serveur
- ✅ HTTPS uniquement
- ✅ Secrets gérés via GitHub Secrets
- ✅ Scanning de sécurité automatisé (Trivy)
- ✅ Dependencies vérifiées (Dependabot)

## 📋 Historique des Vulnérabilités

Les vulnérabilités corrigées seront documentées ici après leur résolution.

## 🔗 Ressources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Flutter Security](https://docs.flutter.dev/security)
- [Supabase Security](https://supabase.com/docs/guides/platform/security)


