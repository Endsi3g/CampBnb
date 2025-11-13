# Guide d'Ajout d'Emplacements - Campbnb Québec

## Fonctionnalité d'Ajout d'Emplacements

L'application permet aux hôtes d'ajouter de nouveaux emplacements de camping directement depuis la carte.

## Méthodes d'Ajout

### Méthode 1: Long Press sur la Carte

1. Ouvrez l'écran de carte (`FullMapScreen`)
2. Maintenez appuyé (long press) sur l'emplacement désiré
3. Une boîte de dialogue apparaît pour confirmer
4. Cliquez sur "Créer" pour ouvrir le formulaire

### Méthode 2: Bouton Flottant

1. Depuis n'importe quel écran avec la carte
2. Utilisez le `AddLocationButton` (bouton flottant)
3. Le formulaire s'ouvre directement

### Méthode 3: Navigation Directe

```dart
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => AddCampsiteScreen(
initialLatitude: 46.8139, // Optionnel
initialLongitude: -71.2080, // Optionnel
),
),
);
```

## Formulaire d'Ajout

Le formulaire `AddCampsiteScreen` contient:

### Champs Requis
- **Nom de l'emplacement**: Nom du camping
- **Type d'emplacement**: Tente, VR, Chalet, etc.
- **Emplacement sur la carte**: Sélectionné via la carte

### Champs Optionnels
- **Description**: Description détaillée
- **Prix par nuit**: En dollars CAD

### Fonctionnalités de la Carte

1. **Sélection par Tap**: Cliquez sur la carte pour sélectionner un emplacement
2. **Recherche d'Adresse**: Utilisez la barre de recherche pour trouver une adresse
3. **Géocodage Inverse**: L'adresse est automatiquement récupérée depuis les coordonnées
4. **Indicateur Visuel**: Un marqueur au centre indique l'emplacement sélectionné

## Utilisation Technique

### Écran Principal

```dart
import 'package:campbnb_quebec/features/map/presentation/screens/add_campsite_screen.dart';

// Navigation vers l'écran d'ajout
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => AddCampsiteScreen(),
),
);
```

### Bouton Flottant

```dart
import 'package:campbnb_quebec/features/map/presentation/widgets/add_location_button.dart';

// Dans votre Scaffold
floatingActionButton: AddLocationButton(),
```

### Intégration dans FullMapScreen

Le `FullMapScreen` gère automatiquement le long press:

```dart
MapboxMapWidget(
onMapLongPress: (lat, lon) {
// Ouvre automatiquement le formulaire d'ajout
},
)
```

## Flux de Données

1. **Sélection d'Emplacement**
- Utilisateur sélectionne un point sur la carte
- Coordonnées (lat, lon) sont capturées
- Géocodage inverse récupère l'adresse

2. **Remplissage du Formulaire**
- Utilisateur remplit les informations
- Validation des champs requis

3. **Soumission**
- Création de l'entité `CampsiteLocation`
- Appel à `MapRepository.createCampsite()`
- Sauvegarde dans Supabase
- Retour à l'écran précédent avec succès

## ️ Structure de la Base de Données

L'emplacement est sauvegardé dans la table `campsites` avec:

```sql
- id (UUID)
- name (TEXT)
- latitude (DOUBLE PRECISION)
- longitude (DOUBLE PRECISION)
- type (TEXT) -- tent, rv, cabin, etc.
- description (TEXT, nullable)
- price_per_night (DOUBLE PRECISION, nullable)
- host_id (UUID, référence vers users)
- is_available (BOOLEAN)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

## Permissions Requises

Pour que les hôtes puissent ajouter des emplacements:

1. **Authentification**: L'utilisateur doit être connecté
2. **Rôle Hôte**: Vérifier que l'utilisateur a le rôle "host"
3. **Permissions Supabase**: RLS (Row Level Security) doit permettre l'insertion

### Exemple de RLS Policy

```sql
-- Permet aux hôtes de créer leurs propres emplacements
CREATE POLICY "Hosts can create campsites"
ON campsites
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = host_id);
```

## Personnalisation

### Modifier les Types d'Emplacements

Dans `campsite_location.dart`, ajoutez de nouveaux types:

```dart
enum CampsiteType {
// ... types existants ...
treehouse, // Nouveau type
}
```

### Modifier les Champs du Formulaire

Dans `add_campsite_screen.dart`, ajoutez de nouveaux champs:

```dart
TextFormField(
controller: _newFieldController,
decoration: InputDecoration(labelText: 'Nouveau champ'),
)
```

## Dépannage

### L'emplacement ne s'enregistre pas

1. Vérifiez les permissions Supabase (RLS)
2. Vérifiez que l'utilisateur est authentifié
3. Vérifiez les logs pour les erreurs

### La géolocalisation ne fonctionne pas

1. Vérifiez les permissions de localisation
2. Vérifiez que le service Mapbox est configuré
3. Testez sur un appareil réel (pas émulateur)

### L'adresse ne s'affiche pas

1. Vérifiez que le token Mapbox est valide
2. Vérifiez la connexion internet
3. Vérifiez les logs du service Mapbox

## Ressources

- Documentation Mapbox Geocoding: https://docs.mapbox.com/api/search/geocoding/
- Documentation Supabase: https://supabase.com/docs
- Guide d'intégration: `docs/MAPBOX_INTEGRATION.md`

