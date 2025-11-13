# Guide de Configuration - Système de Monitoring

## Vue d'ensemble

Ce guide explique comment configurer et utiliser le système de monitoring d'erreurs pour Campbnb.

## Installation

### 1. Installer les dépendances

```bash
flutter pub get
```

### 2. Configurer Sentry

1. Créer un compte sur [sentry.io](https://sentry.io)
2. Créer un nouveau projet Flutter
3. Récupérer le DSN (Data Source Name)
4. Ajouter dans `.env`:

```env
SENTRY_DSN=https://your-dsn@sentry.io/project-id
```

### 3. Configuration Supabase

Supabase est déjà configuré dans le projet. Le monitoring backend se fait via le Supabase Dashboard.

## Utilisation

### Capturer une erreur

```dart
import 'package:campbnb_quebec/core/monitoring/error_monitoring_service.dart';

try {
// Code qui peut échouer
} catch (e, stackTrace) {
await ErrorMonitoringService().captureException(
e,
stackTrace: stackTrace,
context: {
'component': 'listing_details',
'listing_id': listingId,
},
);
}
```

### Capturer une erreur réseau

```dart
import 'package:campbnb_quebec/core/monitoring/network_error_interceptor.dart';

// Avec Dio
final dio = Dio();
dio.interceptors.add(NetworkErrorInterceptor());

// Avec HTTP
final client = MonitoredHttpClient(http.Client());
```

### Surveiller une opération

```dart
import 'package:campbnb_quebec/core/monitoring/observability_service.dart';

final result = await ObservabilityService().monitorSupabaseOperation(
'load_listings',
() => SupabaseService.from('listings').select(),
);
```

## Dashboard Sentry

1. Aller sur [sentry.io](https://sentry.io)
2. Sélectionner le projet Campbnb
3. Consulter:
- **Issues**: Liste des erreurs
- **Performance**: Temps de réponse
- **Releases**: Erreurs par version
- **Users**: Erreurs par utilisateur

## Alertes

Les alertes sont configurées dans Sentry:
- **Erreurs critiques** → Notification immédiate
- **Erreurs récurrentes** → Notification quotidienne
- **Nouveaux types d'erreurs** → Notification hebdomadaire

## Conformité RGPD

Le système filtre automatiquement:
- Mots de passe
- Tokens
- Informations personnelles sensibles

Les emails sont anonymisés avant envoi.

## Checklist de déploiement

- [ ] Configurer `SENTRY_DSN` dans `.env`
- [ ] Tester la capture d'erreurs en staging
- [ ] Configurer les alertes dans Sentry
- [ ] Vérifier la conformité RGPD
- [ ] Documenter les erreurs fréquentes

## Ressources

- [Documentation Sentry](https://docs.sentry.io/platforms/flutter/)
- [Documentation Supabase](https://supabase.com/docs)
- [Guide des erreurs fréquentes](./ERROR_MONITORING.md)

