# Feature Map - Intégration Mapbox

Cette feature gère toute la cartographie de l'application Campbnb Québec avec Mapbox.

## Structure

```
lib/features/map/
├── domain/
│ ├── entities/
│ │ └── campsite_location.dart # Entités des emplacements
│ ├── repositories/
│ │ └── map_repository.dart # Interface du repository
│ └── services/
│ └── location_service.dart # Service de géolocalisation
├── data/
│ ├── repositories/
│ │ └── map_repository_impl.dart # Implémentation Supabase
│ └── services/
│ ├── location_service_impl.dart # Implémentation géolocalisation
│ └── mapbox_service.dart # Service API Mapbox
└── presentation/
├── screens/
│ └── full_map_screen.dart # Écran carte plein écran
├── widgets/
│ ├── mapbox_map_widget.dart # Widget carte principale
│ ├── campsite_marker.dart # Marqueurs personnalisés
│ ├── map_cluster_manager.dart # Gestionnaire de clustering
│ ├── map_search_bar.dart # Barre de recherche
│ ├── map_filters_sheet.dart # Panneau de filtres
│ ├── map_controls.dart # Contrôles de la carte
│ └── directions_widget.dart # Widget directions
├── providers/
│ └── map_providers.dart # Providers Riverpod
└── services/
└── navigation_service.dart # Service navigation/directions
```

## Configuration

### 1. Variables d'environnement

Ajoutez dans votre fichier `.env`:

```env
MAPBOX_ACCESS_TOKEN=votre_token_mapbox
MAPBOX_STYLE=mapbox://styles/mapbox/outdoors-v12
MAPBOX_NATURE_STYLE=mapbox://styles/mapbox/outdoors-v12
MAPBOX_DARK_STYLE=mapbox://styles/mapbox/dark-v11
```

### 2. Initialisation

Dans `main.dart`, initialisez Mapbox:

```dart
import 'package:campbnb_quebec/core/config/mapbox_config.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

// Initialise Mapbox
await MapboxConfig.initialize();

runApp(MyApp());
}
```

### 3. Configuration Android

Dans `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<application>
<!-- ... -->
<meta-data
android:name="com.mapbox.token"
android:value="YOUR_MAPBOX_TOKEN"/>
</application>
</manifest>
```

### 4. Configuration iOS

Dans `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette application a besoin de votre localisation pour afficher les campings à proximité.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Cette application a besoin de votre localisation pour la navigation.</string>
```

## Utilisation

### Afficher la carte

```dart
import 'package:campbnb_quebec/features/map/presentation/screens/full_map_screen.dart';

// Dans votre navigation
Navigator.push(
context,
MaterialPageRoute(builder: (context) => const FullMapScreen()),
);
```

### Utiliser le widget de carte

```dart
import 'package:campbnb_quebec/features/map/presentation/widgets/mapbox_map_widget.dart';

MapboxMapWidget(
campsites: campsitesList,
onCampsiteTap: (campsite) {
// Gérer le tap sur un emplacement
},
showClusters: true,
showUserLocation: true,
)
```

### Recherche par proximité

```dart
import 'package:campbnb_quebec/features/map/presentation/providers/map_providers.dart';

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
startLat: userLat,
startLon: userLon,
destination: campsite,
profile: 'driving', // ou 'walking', 'cycling'
);
```

## Personnalisation

### Marqueurs personnalisés

Les marqueurs sont personnalisés selon le type d'emplacement dans `campsite_marker.dart`. Pour ajouter un nouveau type:

1. Ajoutez le type dans `CampsiteType` enum
2. Ajoutez l'icône dans `MarkerIconBuilder._getIconDataForType()`
3. Ajoutez la couleur dans `MarkerIconBuilder._getColorForType()`

### Styles de carte

Les styles sont configurables dans `MapboxConfig`. Styles disponibles:
- `outdoors-v12`: Par défaut, adapté pour la nature
- `dark-v11`: Mode sombre
- Styles personnalisés Mapbox Studio

## Sécurité

### Gestion des tokens

️ **IMPORTANT**: Ne jamais commiter le token Mapbox dans le code source.

1. Utilisez toujours le fichier `.env` (dans `.gitignore`)
2. Pour la production, utilisez des variables d'environnement sécurisées
3. Limitez les permissions du token dans le dashboard Mapbox

### Quotas API

Les quotas sont configurés dans `MapboxConfig`:
- Geocoding: 600 requêtes/minute par défaut
- Directions: 10000 requêtes/jour par défaut

Surveillez l'utilisation dans le dashboard Mapbox.

## ️ Base de données

### Schéma Supabase requis

```sql
-- Table campsites
CREATE TABLE campsites (
id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
name TEXT NOT NULL,
latitude DOUBLE PRECISION NOT NULL,
longitude DOUBLE PRECISION NOT NULL,
type TEXT NOT NULL, -- tent, rv, cabin, etc.
description TEXT,
price_per_night DOUBLE PRECISION,
host_id UUID REFERENCES users(id),
image_url TEXT,
rating DOUBLE PRECISION,
review_count INTEGER DEFAULT 0,
is_available BOOLEAN DEFAULT true,
region TEXT,
created_at TIMESTAMP DEFAULT NOW(),
updated_at TIMESTAMP DEFAULT NOW()
);

-- Index pour les recherches géographiques
CREATE INDEX idx_campsites_location ON campsites USING GIST (
ST_MakePoint(longitude, latitude)
);

-- Fonction pour recherche par proximité (nécessite PostGIS)
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
-- ... autres champs
distance DOUBLE PRECISION
) AS $$
BEGIN
RETURN QUERY
SELECT
c.id,
c.name,
c.latitude,
c.longitude,
-- ... autres champs
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
ORDER BY distance;
END;
$$ LANGUAGE plpgsql;
```

## Tests

### Tests unitaires

```dart
// test/features/map/domain/entities/campsite_location_test.dart
void main() {
test('CampsiteLocation should be equal when same id', () {
final location1 = CampsiteLocation(/* ... */);
final location2 = CampsiteLocation(/* ... */);
expect(location1, equals(location2));
});
}
```

### Tests d'intégration

```dart
// test/features/map/data/repositories/map_repository_impl_test.dart
void main() {
test('getCampsitesNearby should return nearby campsites', () async {
final repository = MapRepositoryImpl();
final campsites = await repository.getCampsitesNearby(
latitude: 46.8139,
longitude: -71.2080,
radiusInMeters: 10000,
);
expect(campsites, isNotEmpty);
});
}
```

## Dépannage

### La carte ne s'affiche pas

1. Vérifiez que `MAPBOX_ACCESS_TOKEN` est défini dans `.env`
2. Vérifiez les permissions de localisation
3. Vérifiez les logs pour les erreurs d'initialisation

### Les marqueurs ne s'affichent pas

1. Vérifiez que les campsites sont bien chargés
2. Vérifiez les permissions de la base de données
3. Vérifiez les logs du cluster manager

### Erreurs de géolocalisation

1. Vérifiez les permissions dans `AndroidManifest.xml` et `Info.plist`
2. Vérifiez que le service de localisation est activé
3. Testez sur un appareil réel (pas toujours disponible sur émulateur)

## Ressources

- [Documentation Mapbox Flutter](https://docs.mapbox.com/flutter/maps/guides/)
- [Mapbox Styles](https://docs.mapbox.com/api/maps/styles/)
- [Mapbox Geocoding API](https://docs.mapbox.com/api/search/geocoding/)
- [Mapbox Directions API](https://docs.mapbox.com/api/navigation/directions/)

## Contribution

Pour contribuer à cette feature:

1. Suivez l'architecture domain-driven
2. Ajoutez des tests pour les nouvelles fonctionnalités
3. Documentez les changements dans ce README
4. Respectez les conventions de code du projet


