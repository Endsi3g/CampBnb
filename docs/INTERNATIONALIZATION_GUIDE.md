# Guide d'Internationalisation - Campbnb

## Vue d'ensemble

Ce guide explique comment utiliser le système d'internationalisation (i18n) de Campbnb pour supporter plusieurs langues et régions.

## Langues Supportées

- Français (Canada)
- Anglais (États-Unis)
- Anglais (Canada)
- Espagnol (Mexique)
- Français (France)
- Anglais (Royaume-Uni)
- Espagnol (Espagne)
- Allemand
- Italien
- Portugais (Brésil)
- Espagnol (Argentine)
- Espagnol (Chili)
- Espagnol (Colombie)
- Espagnol (Pérou)
- Japonais
- Chinois (Simplifié)
- Coréen
- Hindi
- Anglais (Australie)
- Anglais (Nouvelle-Zélande)

## Utilisation de Base

### Dans un Widget

```dart
import 'package:flutter/material.dart';
import '../../core/localization/l10n_helper.dart';

class MyWidget extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Text(context.t('welcome'));
}
}
```

### Formatage des Monnaies

```dart
final price = 50.0;
final formatted = context.formatCurrency(price, currencyCode: 'CAD');
// Résultat: "C$50.00" (en français canadien)
```

### Formatage des Dates

```dart
final date = DateTime.now();
final formatted = context.formatDate(date);
// Résultat: "15 janv. 2024" (en français)
```

### Formatage des Distances

```dart
final distance = 10.5; // km
final formatted = context.formatDistance(distance);
// Résultat: "10.5 km" (en français) ou "6.5 mi" (en anglais US)
```

### Formatage des Températures

```dart
final temp = 25.0; // Celsius
final formatted = context.formatTemperature(temp);
// Résultat: "25°C" (en français) ou "77°F" (en anglais US)
```

## Changer de Langue

### Via le Widget de Sélection

```dart
import 'features/settings/presentation/widgets/language_selector.dart';

LanguageSelector()
```

### Programmatiquement

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/locale_provider.dart';
import 'core/localization/app_locale.dart';

// Dans un ConsumerWidget
ref.read(localeProvider.notifier).setLocale(
AppLocale.supportedLocales.firstWhere(
(locale) => locale.languageCode == 'en',
).locale,
);
```

## Ajouter une Nouvelle Traduction

### 1. Ajouter la clé dans les fichiers JSON

**assets/translations/fr-CA.json:**
```json
{
"my_new_key": "Ma nouvelle traduction"
}
```

**assets/translations/en-US.json:**
```json
{
"my_new_key": "My new translation"
}
```

### 2. Utiliser dans le code

```dart
Text(context.t('my_new_key'))
```

## Thèmes Culturels

Le système applique automatiquement des thèmes adaptés à chaque culture:

- **Canada**: Vert forêt québécois
- **États-Unis**: Bleu américain
- **France**: Bleu français
- **Espagne**: Rouge espagnol
- **Mexique**: Vert mexicain
- **Brésil**: Vert brésilien
- **Japon**: Rouge japonais
- **Chine**: Rouge chinois
- **Corée**: Rouge coréen
- **Inde**: Orange indien

## Gestion des Devises

### Conversion de Devises

```dart
import 'core/localization/currency_service.dart';

final converted = CurrencyService.convertCurrency(
amount: 100.0,
fromCurrency: 'CAD',
toCurrency: 'USD',
);
```

### Formatage selon la Locale

```dart
final formatted = CurrencyService.formatAmount(
amount: 100.0,
currencyCode: 'CAD',
locale: Locale('fr', 'CA'),
);
// Résultat: "C$100,00"
```

## Gestion des Fuseaux Horaires

```dart
import 'core/localization/timezone_service.dart';

// Initialiser (déjà fait dans main.dart)
await TimezoneService.initialize();

// Convertir vers un fuseau horaire
final tzDateTime = TimezoneService.convertToTimezone(
DateTime.now(),
'America/Toronto',
);

// Obtenir l'heure actuelle dans un fuseau
final now = TimezoneService.nowInTimezone('Europe/Paris');
```

## Unités de Mesure

Le système détecte automatiquement les préférences selon le pays:

- **Distance**: km (sauf US, LR, MM → miles)
- **Température**: Celsius (sauf US, BS, BZ, KY, PW → Fahrenheit)
- **Altitude**: mètres (sauf US → pieds)

```dart
import 'core/localization/unit_converter.dart';

// Conversion
final miles = UnitConverter.kmToMiles(10.0);
final fahrenheit = UnitConverter.celsiusToFahrenheit(25.0);

// Formatage
final formatted = UnitConverter.formatDistance(
distanceInKm: 10.0,
useImperial: false,
);
```

## ️ Base de Données

Les traductions sont stockées dans la base de données:

- `listing_translations`: Traductions des listings
- `activity_translations`: Traductions des activités
- `regions`: Régions géographiques
- `regional_settings`: Paramètres régionaux

### Récupérer une Traduction de Listing

```sql
SELECT * FROM get_listing_translation(
'listing-uuid',
'fr',
'CA'
);
```

## Configuration

### Ajouter une Nouvelle Locale

1. Ajouter dans `lib/core/localization/app_locale.dart`:

```dart
AppLocale(
languageCode: 'pt',
countryCode: 'PT',
name: 'Portuguese (Portugal)',
nativeName: 'Português (Portugal)',
flag: '',
currencyCode: 'EUR',
),
```

2. Créer le fichier de traduction `assets/translations/pt-PT.json`

3. Ajouter le thème culturel dans `lib/core/design/cultural_theme.dart`

## Exemple Complet

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/l10n_helper.dart';

class ExampleScreen extends ConsumerWidget {
@override
Widget build(BuildContext context, WidgetRef ref) {
final price = 75.50;
final date = DateTime.now();
final distance = 15.3;

return Scaffold(
appBar: AppBar(
title: Text(context.t('welcome')),
),
body: Column(
children: [
Text(context.t('search')),
Text(context.formatCurrency(price)),
Text(context.formatDate(date)),
Text(context.formatDistance(distance)),
],
),
);
}
}
```

## Dépannage

### La traduction ne s'affiche pas

1. Vérifier que la clé existe dans le fichier JSON
2. Vérifier que le fichier JSON est dans `assets/translations/`
3. Vérifier que `pubspec.yaml` inclut `assets/translations/`
4. Redémarrer l'application

### La locale ne change pas

1. Vérifier que `localeProvider` est utilisé dans `MaterialApp`
2. Vérifier que la locale est dans `AppLocale.supportedLocales`
3. Vérifier que le fichier de traduction existe

## Ressources

- [Documentation Flutter i18n](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [Package intl](https://pub.dev/packages/intl)
- [Roadmap de déploiement](./DEPLOYMENT_ROADMAP.md)

