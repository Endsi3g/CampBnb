# Configuration des Alertes Sentry

## Vue d'ensemble

Ce guide explique comment configurer les alertes dans Sentry pour être notifié des erreurs critiques et importantes.

## Accès au Dashboard Sentry

1. Aller sur [sentry.io](https://sentry.io)
2. Se connecter avec votre compte
3. Sélectionner le projet **Campbnb**

## Configuration des Alertes

### 1. Alertes pour Erreurs Critiques (Fatal)

**Objectif**: Être notifié immédiatement des erreurs fatales

**Configuration**:

1. Aller dans **Settings** → **Alerts** → **Create Alert Rule**
2. Nommer l'alerte: `Erreurs Fatales - Notification Immédiate`
3. Conditions:
   - **When**: `An event is seen`
   - **If**: `The event's level is equal to fatal`
   - **Then**: `Send a notification via Email, Slack, etc.`

**Exemple de configuration JSON**:

```json
{
  "conditions": [
    {
      "id": "sentry.rules.conditions.event_frequency.EventFrequencyCondition",
      "interval": "1m",
      "value": 1
    },
    {
      "id": "sentry.rules.conditions.tagged_event.TaggedEventCondition",
      "key": "level",
      "value": "fatal"
    }
  ],
  "actions": [
    {
      "id": "sentry.rules.actions.notify_event.NotifyEventAction",
      "channel": "#alerts-critical"
    }
  ]
}
```

### 2. Alertes pour Erreurs Récurrentes

**Objectif**: Être notifié quand une erreur se répète plusieurs fois

**Configuration**:

1. Aller dans **Settings** → **Alerts** → **Create Alert Rule**
2. Nommer l'alerte: `Erreurs Récurrentes - Notification Quotidienne`
3. Conditions:
   - **When**: `An event is seen`
   - **If**: `The event is seen more than 10 times in 1 hour`
   - **Then**: `Send a notification`

**Exemple de configuration**:

```json
{
  "conditions": [
    {
      "id": "sentry.rules.conditions.event_frequency.EventFrequencyCondition",
      "interval": "1h",
      "value": 10
    }
  ],
  "actions": [
    {
      "id": "sentry.rules.actions.notify_event.NotifyEventAction",
      "channel": "#alerts-recurring"
    }
  ]
}
```

### 3. Alertes pour Nouveaux Types d'Erreurs

**Objectif**: Découvrir de nouveaux types d'erreurs

**Configuration**:

1. Aller dans **Settings** → **Alerts** → **Create Alert Rule**
2. Nommer l'alerte: `Nouveaux Types d'Erreurs - Notification Hebdomadaire`
3. Conditions:
   - **When**: `A new issue is created`
   - **Then**: `Send a notification`

### 4. Alertes pour Erreurs par Version

**Objectif**: Surveiller les erreurs d'une version spécifique

**Configuration**:

1. Aller dans **Settings** → **Alerts** → **Create Alert Rule**
2. Nommer l'alerte: `Erreurs Version 1.0.0`
3. Conditions:
   - **When**: `An event is seen`
   - **If**: `The event's release is equal to 1.0.0`
   - **Then**: `Send a notification`

### 5. Alertes pour Erreurs Réseau

**Objectif**: Surveiller les problèmes de connectivité

**Configuration**:

1. Aller dans **Settings** → **Alerts** → **Create Alert Rule**
2. Nommer l'alerte: `Erreurs Réseau`
3. Conditions:
   - **When**: `An event is seen`
   - **If**: `The event's tags contain network_error`
   - **Then**: `Send a notification`

### 6. Alertes pour Problèmes de Performance

**Objectif**: Surveiller les opérations lentes

**Configuration**:

1. Aller dans **Settings** → **Alerts** → **Create Alert Rule**
2. Nommer l'alerte: `Problèmes de Performance`
3. Conditions:
   - **When**: `A performance issue is detected`
   - **If**: `The transaction duration is greater than 3 seconds`
   - **Then**: `Send a notification`

## Configuration des Canaux de Notification

### Email

1. Aller dans **Settings** → **Notifications**
2. Configurer les adresses email
3. Choisir la fréquence (immédiat, quotidien, hebdomadaire)

### Slack

1. Aller dans **Settings** → **Integrations** → **Slack**
2. Connecter votre workspace Slack
3. Configurer les canaux:
   - `#alerts-critical` pour les erreurs critiques
   - `#alerts-recurring` pour les erreurs récurrentes
   - `#alerts-performance` pour les problèmes de performance

**Exemple de webhook Slack**:

```json
{
  "text": "🚨 Erreur critique détectée",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Erreur Critique*\nUne erreur fatale a été détectée dans l'application Campbnb."
      }
    }
  ]
}
```

### Discord (optionnel)

1. Aller dans **Settings** → **Integrations** → **Discord**
2. Connecter votre serveur Discord
3. Configurer les canaux de notification

## Filtres et Conditions Avancées

### Filtrer par Environnement

```json
{
  "conditions": [
    {
      "id": "sentry.rules.conditions.tagged_event.TaggedEventCondition",
      "key": "environment",
      "value": "production"
    }
  ]
}
```

### Filtrer par Utilisateur

```json
{
  "conditions": [
    {
      "id": "sentry.rules.conditions.event_attribute.EventAttributeCondition",
      "attribute": "user.id",
      "value": "specific-user-id"
    }
  ]
}
```

### Filtrer par Composant

```json
{
  "conditions": [
    {
      "id": "sentry.rules.conditions.tagged_event.TaggedEventCondition",
      "key": "component",
      "value": "payment_service"
    }
  ]
}
```

## Exemples de Règles Complètes

### Règle 1: Erreurs Critiques en Production

```json
{
  "name": "Erreurs Critiques Production",
  "conditions": [
    {
      "id": "sentry.rules.conditions.tagged_event.TaggedEventCondition",
      "key": "level",
      "value": "fatal"
    },
    {
      "id": "sentry.rules.conditions.tagged_event.TaggedEventCondition",
      "key": "environment",
      "value": "production"
    }
  ],
  "actions": [
    {
      "id": "sentry.rules.actions.notify_event.NotifyEventAction",
      "channel": "#alerts-critical"
    },
    {
      "id": "sentry.rules.actions.notify_event_service.NotifyEventServiceAction",
      "service": "email"
    }
  ]
}
```

### Règle 2: Erreurs Réseau Récurrentes

```json
{
  "name": "Erreurs Réseau Récurrentes",
  "conditions": [
    {
      "id": "sentry.rules.conditions.event_frequency.EventFrequencyCondition",
      "interval": "1h",
      "value": 5
    },
    {
      "id": "sentry.rules.conditions.tagged_event.TaggedEventCondition",
      "key": "type",
      "value": "network_error"
    }
  ],
  "actions": [
    {
      "id": "sentry.rules.actions.notify_event.NotifyEventAction",
      "channel": "#alerts-network"
    }
  ]
}
```

## Checklist de Configuration

- [ ] Configurer les alertes pour erreurs fatales
- [ ] Configurer les alertes pour erreurs récurrentes
- [ ] Configurer les alertes pour nouveaux types d'erreurs
- [ ] Configurer les alertes pour problèmes de performance
- [ ] Configurer les canaux de notification (Email, Slack)
- [ ] Tester les alertes avec des erreurs simulées
- [ ] Documenter les règles d'alerte pour l'équipe

## Tests des Alertes

Pour tester que les alertes fonctionnent:

1. **Tester une erreur fatale**:
   ```dart
   await ErrorMonitoringService().captureException(
     Exception('Test fatal error'),
     severity: ErrorSeverity.fatal,
   );
   ```

2. **Tester une erreur réseau**:
   ```dart
   await ErrorMonitoringService().captureNetworkError(
     url: 'https://api.example.com/test',
     statusCode: 500,
   );
   ```

3. **Vérifier dans Sentry**:
   - Aller dans **Issues**
   - Vérifier que l'erreur apparaît
   - Vérifier que la notification a été envoyée

## Ressources

- [Documentation Sentry Alerts](https://docs.sentry.io/product/alerts/)
- [Sentry Rules API](https://docs.sentry.io/api/alerts/)
- [Slack Integration](https://docs.sentry.io/product/integrations/notification-incidents/slack/)

