# Service de Validation

Ce service centralise toutes les validations de formulaires dans l'application.

## Utilisation

```dart
import 'package:campbnb/core/validation/form_validators.dart';

// Dans un TextFormField
TextFormField(
  validator: FormValidators.email,
  // ...
)

// Validation personnalisée
TextFormField(
  validator: (value) => FormValidators.required(value, fieldName: 'Nom'),
  // ...
)
```

## Validateurs disponibles

- `email` - Validation d'email
- `password` - Validation de mot de passe (force minimale)
- `name` - Validation de nom/prénom
- `phone` - Validation de numéro de téléphone
- `price` - Validation de prix
- `date` - Validation de date
- `dateRange` - Validation de plage de dates
- `guests` - Validation du nombre de personnes
- `postalCode` - Validation de code postal canadien
- `description` - Validation de description
- `required` - Validation de champ requis
- `url` - Validation d'URL
- `positiveNumber` - Validation de nombre positif
- `positiveDecimal` - Validation de nombre décimal positif

