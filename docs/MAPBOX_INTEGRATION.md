# Guide d'Intégration Mapbox - Campbnb Québec

## Vue d'ensemble

Ce guide détaille l'intégration complète de Mapbox dans l'application Campbnb Québec pour la gestion cartographique des emplacements de camping.

## Fonctionnalités Implémentées

### Fonctionnalités de base
- [x] Affichage de cartes interactives Mapbox
- [x] Géolocalisation en temps réel
- [x] Affichage des emplacements de camping sur la carte
- [x] Sélection de nouveaux emplacements (drag, drop, search)
- [x] Marqueurs personnalisés par type d'emplacement
- [x] Clustering des marqueurs
- [x] Filtres interactifs (type, prix, région)
- [x] Recherche par région et proximité
- [x] Navigation et directions
- [x] Points d'intérêt (POI)
- [x] Surcouche météo (optionnelle)

## Installation

### Étape 1: Obtenir un token Mapbox

1. Créez un compte sur [mapbox.com](https://www.mapbox.com)
2. Accédez à votre [page de tokens](https://account.mapbox.com/access-tokens/)
3. Créez un nouveau token ou utilisez le token par défaut
4. **Important**: Limitez les permissions du token (scopes) selon vos besoins

### Étape 2: Configuration du projet

#### 2.1 Variables d'environnement

Créez ou modifiez le fichier `.env` à la racine du projet:

```env
# Mapbox Configuration
MAPBOX_ACCESS_TOKEN=pk.eyJ1IjoieW91cnVzZXJuYW1lIiwiYSI6ImN...votre_token_ici
MAPBOX_STYLE=mapbox://styles/mapbox/outdoors-v12
MAPBOX_NATURE_STYLE=mapbox://styles/mapbox/outdoors-v12
MAPBOX_DARK_STYLE=mapbox://styles/mapbox/dark-v11

# Limites de taux (optionnel)
MAPBOX_GEOCODING_RATE_LIMIT=600
MAPBOX_DIRECTIONS_RATE_LIMIT=10000
MAPBOX_SEARCH_RADIUS=50000
```

#### 2.2 Configuration Android

**android/app/src/main/AndroidManifest.xml**:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
<!-- Permissions -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<application>
<!-- ... autres configurations ... -->

<!-- Token Mapbox (optionnel, peut être défini dans le code) -->
<meta-data
android:name="com.mapbox.token"
android:value="YOUR_MAPBOX_TOKEN"/>
</application>
</manifest>
```

**android/app/build.gradle**:

```gradle
android {
// ...
defaultConfig {
// ...
minSdkVersion 21 // Mapbox nécessite au minimum API 21
}
}
```

#### 2.3 Configuration iOS

**ios/Runner/Info.plist**:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette application a besoin de votre localisation pour afficher les campings à proximité et vous guider.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Cette application a besoin de votre localisation pour la navigation en temps réel.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>Cette application a besoin de votre localisation pour la navigation.</string>
```

**ios/Podfile**:

```ruby
platform:ios, '12.0' # Mapbox nécessite iOS 12.0 minimum
```

### Étape 3: Installation des dépendances

```bash
flutter pub get
```

### Étape 4: Initialisation dans main.dart

```dart
import 'package:campbnb_quebec/core/config/mapbox_config.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

// Initialise Mapbox
await MapboxConfig.initialize();

// ... autres initialisations ...

runApp(MyApp());
}
```

## Utilisation

### Afficher la carte plein écran

```dart
import 'package:campbnb_quebec/features/map/presentation/screens/full_map_screen.dart';

Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const FullMapScreen(),
),
);
```

### Utiliser le widget de carte dans un écran

```dart
import 'package:campbnb_quebec/features/map/presentation/widgets/mapbox_map_widget.dart';

MapboxMapWidget(
campsites: campsitesList,
onCampsiteTap: (campsite) {
// Naviguer vers les détails
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => CampsiteDetailsScreen(campsite: campsite),
),
);
},
showClusters: true,
showUserLocation: true,
initialLatitude: 46.8139, // Québec
initialLongitude: -71.2080,
initialZoom: 7.0,
)
```

### Recherche par proximité

```dart
import 'package:campbnb_quebec/features/map/presentation/providers/map_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final repository = ref.read(mapRepositoryProvider);
final nearbyCampsites = await repository.getCampsitesNearby(
latitude: 46.8139,
longitude: -71.2080,
radiusInMeters: 50000, // 50km
);
```

### Obtenir les directions

```dart
import 'package:campbnb_quebec/features/map/presentation/services/navigation_service.dart';

final navigationService = NavigationService();
final route = await navigationService.getDirectionsToCampsite(
startLat: userLatitude,
startLon: userLongitude,
destination: campsite,
profile: 'driving', // 'driving', 'walking', ou 'cycling'
);

if (route != null) {
print('Distance: ${route.formattedDistance}');
print('Durée: ${route.formattedDuration}');
}
```

## Personnalisation

### Styles de carte

Les styles sont configurables dans `MapboxConfig`. Vous pouvez:

1. Utiliser un style Mapbox prédéfini:
- `outdoors-v12`: Parfait pour la nature (recommandé pour le Québec)
- `satellite-v2`: Vue satellite
- `dark-v11`: Mode sombre
- `streets-v12`: Vue routière classique

2. Créer un style personnalisé dans [Mapbox Studio](https://studio.mapbox.com/):
- Créez votre style
- Copiez l'URL du style (format: `mapbox://styles/votre-username/votre-style-id`)
- Ajoutez-la dans `.env`: `MAPBOX_NATURE_STYLE=votre-url`

### Marqueurs personnalisés

Les marqueurs sont personnalisés dans `campsite_marker.dart`. Pour ajouter un nouveau type:

1. Ajoutez le type dans l'enum `CampsiteType`
2. Ajoutez l'icône dans `MarkerIconBuilder._getIconDataForType()`
3. Ajoutez la couleur dans `MarkerIconBuilder._getColorForType()`

Exemple:

```dart
// Dans campsite_location.dart
enum CampsiteType {
// ... types existants ...
treehouse, // Nouveau type
}

// Dans campsite_marker.dart
static IconData _getIconDataForType(CampsiteType type) {
switch (type) {
// ... autres cas ...
case CampsiteType.treehouse:
return Icons.forest; // Icône appropriée
}
}
```

## Sécurité

### Gestion des tokens

️ **CRITIQUE**: Ne jamais commiter le token Mapbox dans le code source.

1. **Développement**:
- Utilisez `.env` (dans `.gitignore`)
- Ne partagez jamais le token dans les messages/emails

2. **Production**:
- Utilisez des variables d'environnement sécurisées
- Limitez les scopes du token dans le dashboard Mapbox
- Utilisez des tokens différents pour dev/staging/prod

3. **Restrictions de domaine**:
- Dans le dashboard Mapbox, limitez les domaines autorisés
- Activez les restrictions d'URL si nécessaire

### Quotas et limites

Surveillez votre utilisation dans le [dashboard Mapbox](https://account.mapbox.com/):

- **Geocoding API**: 600 requêtes/minute (par défaut)
- **Directions API**: 10000 requêtes/jour (par défaut)
- **Styles API**: Illimité (avec token valide)

Pour augmenter les limites, contactez Mapbox ou passez à un plan payant.

## ️ Base de données

### Schéma Supabase requis

Voir `lib/features/map/README.md` pour le schéma complet.

### Fonction PostGIS pour recherche par proximité

```sql
-- Activez l'extension PostGIS dans Supabase
CREATE EXTENSION IF NOT EXISTS postgis;

-- Créez la fonction de recherche par proximité
CREATE OR REPLACE FUNCTION get_campsites_nearby(
lat DOUBLE PRECISION,
lon DOUBLE PRECISION,
radius_meters DOUBLE PRECISION
)
RETURNS TABLE (
id UUID,
name TEXT,
latitude DOUBLE PRECISION,
longitude DOUBLE PRECISION,
type TEXT,
price_per_night DOUBLE PRECISION,
distance DOUBLE PRECISION
) AS $$
BEGIN
RETURN QUERY
SELECT
c.id,
c.name,
c.latitude,
c.longitude,
c.type,
c.price_per_night,
ST_Distance(
ST_MakePoint(c.longitude, c.latitude)::geography,
ST_MakePoint(lon, lat)::geography
) AS distance
FROM campsites c
WHERE ST_DWithin(
ST_MakePoint(c.longitude, c.latitude)::geography,
ST_MakePoint(lon, lat)::geography,
radius_meters
)
AND c.is_available = true
ORDER BY distance
LIMIT 50;
END;
$$ LANGUAGE plpgsql;
```

## Tests

### Tests unitaires

```dart
// test/features/map/domain/entities/campsite_location_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/features/map/domain/entities/campsite_location.dart';

void main() {
group('CampsiteLocation', () {
test('should create a valid campsite location', () {
final location = CampsiteLocation(
id: '1',
name: 'Camping Test',
latitude: 46.8139,
longitude: -71.2080,
type: CampsiteType.tent,
);

expect(location.id, '1');
expect(location.name, 'Camping Test');
expect(location.latitude, 46.8139);
});
});
}
```

### Tests d'intégration

```dart
// test/features/map/data/repositories/map_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/features/map/data/repositories/map_repository_impl.dart';

void main() {
group('MapRepositoryImpl', () {
test('getCampsitesNearby should return nearby campsites', () async {
final repository = MapRepositoryImpl();
final campsites = await repository.getCampsitesNearby(
latitude: 46.8139,
longitude: -71.2080,
radiusInMeters: 10000,
);

expect(campsites, isA<List<CampsiteLocation>>());
});
});
}
```

## Dépannage

### La carte ne s'affiche pas

1. Vérifiez que `MAPBOX_ACCESS_TOKEN` est défini dans `.env`
2. Vérifiez que `MapboxConfig.initialize()` est appelé dans `main.dart`
3. Vérifiez les logs pour les erreurs d'initialisation
4. Vérifiez que le token est valide dans le dashboard Mapbox

### Les marqueurs ne s'affichent pas

1. Vérifiez que les campsites sont bien chargés depuis Supabase
2. Vérifiez les permissions de la base de données
3. Vérifiez les logs du cluster manager
4. Vérifiez que les coordonnées sont valides (latitude: -90 à 90, longitude: -180 à 180)

### Erreurs de géolocalisation

1. Vérifiez les permissions dans `AndroidManifest.xml` et `Info.plist`
2. Vérifiez que le service de localisation est activé sur l'appareil
3. Testez sur un appareil réel (la géolocalisation peut ne pas fonctionner sur émulateur)
4. Vérifiez que `LocationService` a les bonnes permissions

### Erreurs API Mapbox

1. Vérifiez que le token est valide et non expiré
2. Vérifiez les quotas dans le dashboard Mapbox
3. Vérifiez les restrictions de domaine/URL du token
4. Vérifiez la connexion internet

## Ressources

- [Documentation Mapbox Flutter](https://docs.mapbox.com/flutter/maps/guides/)
- [Mapbox Styles](https://docs.mapbox.com/api/maps/styles/)
- [Mapbox Geocoding API](https://docs.mapbox.com/api/search/geocoding/)
- [Mapbox Directions API](https://docs.mapbox.com/api/navigation/directions/)
- [Mapbox Studio](https://studio.mapbox.com/)
- [PostGIS Documentation](https://postgis.net/documentation/)

## Support

Pour toute question ou problème:

1. Consultez la documentation dans `lib/features/map/README.md`
2. Vérifiez les logs de l'application
3. Consultez la [documentation Mapbox](https://docs.mapbox.com/)
4. Contactez l'équipe de développement

---

**Dernière mise à jour**: 2024


