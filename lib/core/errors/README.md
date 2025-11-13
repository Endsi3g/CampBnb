# Service de Gestion des Erreurs

Ce service centralise la gestion des messages d'erreur pour l'utilisateur final.

## Utilisation

```dart
import 'package:campbnb/core/errors/error_message_service.dart';

try {
  // Code qui peut échouer
} catch (e) {
  final message = ErrorMessageService.instance.getUserMessage(e);
  // Afficher le message à l'utilisateur
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// Avec contexte
final message = ErrorMessageService.instance.getContextMessage(
  'reservation_create',
  customMessage: 'Impossible de créer la réservation',
);
```

## Fonctionnalités

- Conversion automatique des exceptions en messages utilisateur
- Gestion des erreurs réseau (DioException)
- Gestion des codes HTTP
- Messages contextuels par fonctionnalité
- Messages d'erreur cohérents dans toute l'application

