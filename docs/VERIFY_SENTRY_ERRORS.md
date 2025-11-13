# Vérification des Erreurs dans Sentry

## Vue d'ensemble

Ce guide explique comment vérifier dans Sentry que les erreurs sont bien capturées avec le contexte correct.

## Accès au Dashboard Sentry

1. Aller sur [sentry.io](https://sentry.io)
2. Se connecter avec votre compte
3. Sélectionner le projet **Campbnb**

## Vérification des Erreurs

### 1. Liste des Issues

**Où**: **Issues** dans le menu principal

**Ce qu'il faut vérifier**:
- ✅ Les erreurs apparaissent dans la liste
- ✅ Le titre de l'erreur est descriptif
- ✅ Le niveau de sévérité est correct (fatal, error, warning)
- ✅ L'environnement est correct (production, staging, development)
- ✅ La version de l'app est indiquée

### 2. Détails d'une Erreur

**Où**: Cliquer sur une erreur dans la liste

**Ce qu'il faut vérifier**:

#### Informations Générales
- ✅ **Message**: Le message d'erreur est clair
- ✅ **Stack Trace**: Le stack trace est complet
- ✅ **Timestamp**: La date et l'heure sont correctes
- ✅ **User**: L'utilisateur affecté (si disponible)
- ✅ **Release**: La version de l'app

#### Tags
- ✅ **platform**: iOS, Android, Web, Windows
- ✅ **environment**: production, staging, development
- ✅ **component**: Le composant où l'erreur s'est produite
- ✅ **type**: Le type d'erreur (network_error, performance, etc.)

#### Context
- ✅ **app_version**: La version de l'app
- ✅ **build_number**: Le numéro de build
- ✅ **component**: Le composant concerné
- ✅ **operation**: L'opération en cours
- ✅ **user**: Les informations utilisateur (anonymisées)

#### Breadcrumbs
- ✅ Les breadcrumbs sont présents
- ✅ Les actions utilisateur sont tracées
- ✅ Les requêtes réseau sont enregistrées
- ✅ Les navigations sont suivies

### 3. Performance Monitoring

**Où**: **Performance** dans le menu principal

**Ce qu'il faut vérifier**:
- ✅ Les transactions sont enregistrées
- ✅ Les temps de réponse sont mesurés
- ✅ Les opérations lentes sont identifiées
- ✅ Les problèmes de performance sont détectés

### 4. Releases

**Où**: **Releases** dans le menu principal

**Ce qu'il faut vérifier**:
- ✅ Les releases sont enregistrées
- ✅ Les erreurs sont associées aux bonnes versions
- ✅ Les statistiques par version sont disponibles

## Checklist de Vérification

### Pour chaque erreur capturée:

- [ ] L'erreur apparaît dans la liste des Issues
- [ ] Le message d'erreur est clair et descriptif
- [ ] Le stack trace est complet
- [ ] Les tags sont correctement renseignés
- [ ] Le contexte est enrichi avec les bonnes informations
- [ ] Les breadcrumbs sont présents
- [ ] L'utilisateur est identifié (si applicable)
- [ ] La version de l'app est indiquée
- [ ] L'environnement est correct

### Pour les erreurs réseau:

- [ ] L'URL est présente dans le contexte
- [ ] Le code de statut HTTP est indiqué
- [ ] La méthode HTTP est spécifiée
- [ ] Les données de requête sont présentes (si non sensibles)

### Pour les erreurs de performance:

- [ ] La transaction est enregistrée
- [ ] La durée est mesurée
- [ ] L'opération est identifiée
- [ ] Le contexte de performance est présent

## Exemples de Vérification

### Exemple 1: Erreur Simple

**Erreur capturée**:
```dart
await ErrorMonitoringService().captureException(
  Exception('Test error'),
  context: {
    'component': 'listing_details',
    'listing_id': '123',
  },
);
```

**Vérification dans Sentry**:
1. Aller dans **Issues**
2. Chercher "Test error"
3. Vérifier:
   - Message: "Test error"
   - Tag `component`: "listing_details"
   - Context `listing_id`: "123"

### Exemple 2: Erreur Réseau

**Erreur capturée**:
```dart
await ErrorMonitoringService().captureNetworkError(
  url: 'https://api.example.com/listings',
  statusCode: 500,
  method: 'GET',
);
```

**Vérification dans Sentry**:
1. Aller dans **Issues**
2. Chercher "Network Error: 500"
3. Vérifier:
   - Tag `type`: "network_error"
   - Context `url`: "https://api.example.com/listings"
   - Context `status_code`: 500
   - Context `method`: "GET"

### Exemple 3: Problème de Performance

**Problème capturé**:
```dart
await ErrorMonitoringService().capturePerformanceIssue(
  operation: 'load_listings',
  duration: const Duration(seconds: 5),
);
```

**Vérification dans Sentry**:
1. Aller dans **Performance**
2. Chercher "load_listings"
3. Vérifier:
   - Transaction: "load_listings"
   - Durée: ~5000ms
   - Alerte de performance déclenchée

## Filtres Utiles

### Filtrer par Environnement

Dans **Issues**, utiliser le filtre:
- **Environment**: `production`, `staging`, `development`

### Filtrer par Composant

Dans **Issues**, utiliser le filtre:
- **Tags**: `component:listing_details`

### Filtrer par Type d'Erreur

Dans **Issues**, utiliser le filtre:
- **Tags**: `type:network_error`

### Filtrer par Version

Dans **Issues**, utiliser le filtre:
- **Release**: `1.0.0`

## Recherche Avancée

Utiliser la syntaxe de recherche Sentry:

```
is:unresolved environment:production level:error
```

```
component:payment_service type:network_error
```

```
release:1.0.0 is:unresolved
```

## Dépannage

### Les erreurs n'apparaissent pas

1. Vérifier que `SENTRY_DSN` est configuré
2. Vérifier la connexion internet
3. Vérifier les logs de l'application
4. Vérifier que Sentry est bien initialisé

### Le contexte est incomplet

1. Vérifier que le contexte est bien passé à `captureException()`
2. Vérifier que les données ne sont pas filtrées (RGPD)
3. Vérifier les logs pour voir si l'erreur est capturée

### Les breadcrumbs sont absents

1. Vérifier que `addBreadcrumb()` est appelé
2. Vérifier que les breadcrumbs sont ajoutés avant l'erreur
3. Vérifier la configuration Sentry

## Prochaines Étapes

Après avoir vérifié que les erreurs sont bien capturées:

1. Configurer les alertes (voir `SENTRY_ALERTS_SETUP.md`)
2. Analyser les erreurs les plus fréquentes
3. Prioriser les corrections
4. Surveiller les tendances

## Ressources

- [Documentation Sentry Issues](https://docs.sentry.io/product/issues/)
- [Documentation Sentry Performance](https://docs.sentry.io/product/performance/)
- [Guide de configuration](./MONITORING_SETUP.md)

