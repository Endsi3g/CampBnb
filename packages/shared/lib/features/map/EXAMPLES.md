# Exemples d'utilisation - Feature Map

Ce fichier contient des exemples pratiques d'utilisation de la feature Map.

## Exemple 1: Afficher la carte avec des campsites

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campbnb_quebec/features/map/presentation/widgets/mapbox_map_widget.dart';
import 'package:campbnb_quebec/features/map/presentation/providers/map_providers.dart';
import 'package:campbnb_quebec/features/map/domain/entities/campsite_location.dart';

class MapExampleScreen extends ConsumerWidget {
const MapExampleScreen({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
final campsitesAsync = ref.watch(campsitesProvider);

return Scaffold(
appBar: AppBar(title: const Text('Carte des campings')),
body: campsitesAsync.when(
data: (campsites) => MapboxMapWidget(
campsites: campsites,
onCampsiteTap: (campsite) {
// Afficher les détails
showDialog(
context: context,
builder: (context) => AlertDialog(
title: Text(campsites.name),
content: Text('Prix: \$${campsite.pricePerNight ?? 'N/A'}/nuit'),
),
);
},
showClusters: true,
showUserLocation: true,
),
loading: () => const Center(child: CircularProgressIndicator()),
error: (error, stack) => Center(child: Text('Erreur: $error')),
),
);
}
}
```

## Exemple 2: Recherche par proximité

```dart
import 'package:flutter/material.dart';
import 'package:campbnb_quebec/features/map/presentation/providers/map_providers.dart';
import 'package:campbnb_quebec/features/map/domain/services/location_service.dart';

class NearbySearchExample extends ConsumerStatefulWidget {
const NearbySearchExample({super.key});

@override
ConsumerState<NearbySearchExample> createState() => _NearbySearchExampleState();
}

class _NearbySearchExampleState extends ConsumerState<NearbySearchExample> {
List<CampsiteLocation> _nearbyCampsites = [];
bool _isLoading = false;

Future<void> _searchNearby() async {
setState(() => _isLoading = true);

final locationService = ref.read(locationServiceProvider);
final repository = ref.read(mapRepositoryProvider);

// Récupère la position actuelle
final position = await locationService.getCurrentPosition();
if (position == null) {
setState(() => _isLoading = false);
return;
}

// Recherche les campsites à proximité (50km)
final campsites = await repository.getCampsitesNearby(
latitude: position.latitude,
longitude: position.longitude,
radiusInMeters: 50000,
);

setState(() {
_nearbyCampsites = campsites;
_isLoading = false;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Recherche à proximité')),
body: Column(
children: [
ElevatedButton(
onPressed: _isLoading ? null: _searchNearby,
child: _isLoading
? const CircularProgressIndicator()
: const Text('Rechercher à proximité'),
),
Expanded(
child: ListView.builder(
itemCount: _nearbyCampsites.length,
itemBuilder: (context, index) {
final campsite = _nearbyCampsites[index];
return ListTile(
title: Text(campsite.name),
subtitle: Text('${campsite.latitude}, ${campsite.longitude}'),
);
},
),
),
],
),
);
}
}
```

## Exemple 3: Filtres interactifs

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campbnb_quebec/features/map/presentation/providers/map_providers.dart';
import 'package:campbnb_quebec/features/map/domain/entities/campsite_location.dart';

class FiltersExample extends ConsumerWidget {
const FiltersExample({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
final filters = ref.watch(mapFiltersProvider);
final filteredCampsites = ref.watch(filteredCampsitesProvider(filters));

return Scaffold(
appBar: AppBar(title: const Text('Filtres')),
body: Column(
children: [
// Contrôles de filtres
Wrap(
spacing: 8,
children: [
FilterChip(
label: const Text('Tente'),
selected: filters.types?.contains(CampsiteType.tent) ?? false,
onSelected: (selected) {
ref.read(mapFiltersProvider.notifier).state = filters.copyWith(
types: selected
? [...(filters.types ?? []), CampsiteType.tent]
: filters.types?.where((t) => t != CampsiteType.tent).toList(),
);
},
),
FilterChip(
label: const Text('VR'),
selected: filters.types?.contains(CampsiteType.rv) ?? false,
onSelected: (selected) {
ref.read(mapFiltersProvider.notifier).state = filters.copyWith(
types: selected
? [...(filters.types ?? []), CampsiteType.rv]
: filters.types?.where((t) => t != CampsiteType.rv).toList(),
);
},
),
],
),

// Liste des campsites filtrés
Expanded(
child: ListView.builder(
itemCount: filteredCampsites.length,
itemBuilder: (context, index) {
final campsite = filteredCampsites[index];
return ListTile(
title: Text(campsite.name),
subtitle: Text('Type: ${campsite.type.name}'),
);
},
),
),
],
),
);
}
}
```

## Exemple 4: Directions vers un camping

```dart
import 'package:flutter/material.dart';
import 'package:campbnb_quebec/features/map/presentation/services/navigation_service.dart';
import 'package:campbnb_quebec/features/map/presentation/widgets/directions_widget.dart';
import 'package:campbnb_quebec/features/map/domain/entities/campsite_location.dart';
import 'package:campbnb_quebec/features/map/presentation/providers/map_providers.dart';

class DirectionsExample extends ConsumerStatefulWidget {
final CampsiteLocation destination;

const DirectionsExample({
super.key,
required this.destination,
});

@override
ConsumerState<DirectionsExample> createState() => _DirectionsExampleState();
}

class _DirectionsExampleState extends ConsumerState<DirectionsExample> {
double? _userLat;
double? _userLon;

@override
void initState() {
super.initState();
_getUserLocation();
}

Future<void> _getUserLocation() async {
final locationService = ref.read(locationServiceProvider);
final position = await locationService.getCurrentPosition();
if (position != null) {
setState(() {
_userLat = position.latitude;
_userLon = position.longitude;
});
}
}

@override
Widget build(BuildContext context) {
if (_userLat == null || _userLon == null) {
return const Scaffold(
body: Center(child: CircularProgressIndicator()),
);
}

final navigationService = NavigationService();

return Scaffold(
appBar: AppBar(title: Text('Directions vers ${widget.destination.name}')),
body: DirectionsWidget(
startLat: _userLat!,
startLon: _userLon!,
destination: widget.destination,
navigationService: navigationService,
),
);
}
}
```

## Exemple 5: Créer un nouvel emplacement (pour les hôtes)

```dart
import 'package:flutter/material.dart';
import 'package:campbnb_quebec/features/map/presentation/providers/map_providers.dart';
import 'package:campbnb_quebec/features/map/domain/entities/campsite_location.dart';
import 'package:uuid/uuid.dart';

class CreateCampsiteExample extends ConsumerStatefulWidget {
final double latitude;
final double longitude;

const CreateCampsiteExample({
super.key,
required this.latitude,
required this.longitude,
});

@override
ConsumerState<CreateCampsiteExample> createState() => _CreateCampsiteExampleState();
}

class _CreateCampsiteExampleState extends ConsumerState<CreateCampsiteExample> {
final _nameController = TextEditingController();
final _priceController = TextEditingController();
CampsiteType _selectedType = CampsiteType.tent;
bool _isLoading = false;

Future<void> _createCampsite() async {
if (_nameController.text.isEmpty) {
return;
}

setState(() => _isLoading = true);

final repository = ref.read(mapRepositoryProvider);
final campsite = CampsiteLocation(
id: const Uuid().v4(),
name: _nameController.text,
latitude: widget.latitude,
longitude: widget.longitude,
type: _selectedType,
pricePerNight: double.tryParse(_priceController.text),
isAvailable: true,
createdAt: DateTime.now(),
);

try {
await repository.createCampsite(campsite);
if (mounted) {
Navigator.pop(context, true);
}
} catch (e) {
// Gérer l'erreur
} finally {
setState(() => _isLoading = false);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Créer un emplacement')),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
TextField(
controller: _nameController,
decoration: const InputDecoration(labelText: 'Nom'),
),
TextField(
controller: _priceController,
decoration: const InputDecoration(labelText: 'Prix par nuit'),
keyboardType: TextInputType.number,
),
DropdownButton<CampsiteType>(
value: _selectedType,
items: CampsiteType.values.map((type) {
return DropdownMenuItem(
value: type,
child: Text(type.name),
);
}).toList(),
onChanged: (value) {
if (value != null) {
setState(() => _selectedType = value);
}
},
),
ElevatedButton(
onPressed: _isLoading ? null: _createCampsite,
child: _isLoading
? const CircularProgressIndicator()
: const Text('Créer'),
),
],
),
),
);
}

@override
void dispose() {
_nameController.dispose();
_priceController.dispose();
super.dispose();
}
}
```

## Exemple 6: Recherche par région

```dart
import 'package:flutter/material.dart';
import 'package:campbnb_quebec/features/map/presentation/providers/map_providers.dart';
import 'package:campbnb_quebec/core/config/mapbox_config.dart';

class RegionSearchExample extends ConsumerStatefulWidget {
const RegionSearchExample({super.key});

@override
ConsumerState<RegionSearchExample> createState() => _RegionSearchExampleState();
}

class _RegionSearchExampleState extends ConsumerState<RegionSearchExample> {
List<CampsiteLocation> _results = [];
String? _selectedRegion;
bool _isLoading = false;

Future<void> _searchByRegion(String region) async {
setState(() {
_selectedRegion = region;
_isLoading = true;
});

final repository = ref.read(mapRepositoryProvider);
final campsites = await repository.searchCampsitesByRegion(region);

setState(() {
_results = campsites;
_isLoading = false;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Recherche par région')),
body: Column(
children: [
// Liste des régions
Expanded(
flex: 1,
child: ListView.builder(
itemCount: MapboxConfig.quebecRegions.length,
itemBuilder: (context, index) {
final region = MapboxConfig.quebecRegions[index];
return ListTile(
title: Text(region),
onTap: () => _searchByRegion(region),
selected: _selectedRegion == region,
);
},
),
),

// Résultats
Expanded(
flex: 2,
child: _isLoading
? const Center(child: CircularProgressIndicator())
: ListView.builder(
itemCount: _results.length,
itemBuilder: (context, index) {
final campsite = _results[index];
return ListTile(
title: Text(campsite.name),
subtitle: Text('${campsite.latitude}, ${campsite.longitude}'),
);
},
),
),
],
),
);
}
}
```


