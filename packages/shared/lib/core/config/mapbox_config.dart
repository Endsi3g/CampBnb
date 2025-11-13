/// Configuration centralisée pour Mapbox
/// Gère les tokens API, quotas, et paramètres de cartes
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class MapboxConfig {
  static final Logger _logger = Logger();

 /// Token d'accès public Mapbox (à définir dans .env)
  /// SECURITE: Ne jamais commiter ce token dans le code source
  static String? get accessToken {
 final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (token == null || token.isEmpty) {
 _logger.w('MAPBOX_ACCESS_TOKEN non défini dans .env');
      _logger.w('Veuillez ajouter MAPBOX_ACCESS_TOKEN dans votre fichier .env');
      // Ne pas retourner de fallback pour la sécurité
      return null;
    }
    return token;
  }

  /// Style de carte par défaut (outdoors pour le Québec)
  static String get defaultStyle => 
 dotenv.env['MAPBOX_STYLE'] ?? 'mapbox://styles/mapbox/outdoors-v12';

  /// Style de carte pour le mode sombre
  static String get darkStyle => 
 dotenv.env['MAPBOX_DARK_STYLE'] ?? 'mapbox://styles/mapbox/dark-v11';

  /// Style de carte personnalisé pour la nature (recommandé pour le Québec)
  static String get natureStyle => 
 dotenv.env['MAPBOX_NATURE_STYLE'] ?? 'mapbox://styles/mapbox/outdoors-v12';

  /// Centre par défaut (Québec, Canada)
  static const double defaultLatitude = 46.8139;
  static const double defaultLongitude = -71.2080;
  static const double defaultZoom = 7.0;

  /// Zoom minimum et maximum
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;

 /// Limite de requêtes par minute pour l'API Geocoding (par défaut: 600)
  static int get geocodingRateLimit => 
 int.tryParse(dotenv.env['MAPBOX_GEOCODING_RATE_LIMIT'] ?? '600') ?? 600;

 /// Limite de requêtes par jour pour l'API Directions (par défaut: 10000)
  static int get directionsRateLimit => 
 int.tryParse(dotenv.env['MAPBOX_DIRECTIONS_RATE_LIMIT'] ?? '10000') ?? 10000;

  /// Timeout des requêtes en secondes (par défaut: 30)
  static Duration get requestTimeout => 
 Duration(seconds: int.tryParse(dotenv.env['MAPBOX_TIMEOUT'] ?? '30') ?? 30);

  /// Rayon de recherche par défaut en mètres (par défaut: 50000 = 50km)
  static int get defaultSearchRadius => 
 int.tryParse(dotenv.env['MAPBOX_SEARCH_RADIUS'] ?? '50000') ?? 50000;

  /// Distance minimale pour le clustering en pixels (par défaut: 50)
  static double get clusterRadius => 
 double.tryParse(dotenv.env['MAPBOX_CLUSTER_RADIUS'] ?? '50') ?? 50.0;

  /// Seuil minimum de zoom pour afficher les clusters (par défaut: 10)
  static double get clusterMinZoom => 
 double.tryParse(dotenv.env['MAPBOX_CLUSTER_MIN_ZOOM'] ?? '10') ?? 10.0;

  /// Vérifie que la configuration est valide
  static bool get isValid {
    if (accessToken == null || accessToken!.isEmpty) {
 _logger.e('Configuration Mapbox invalide: Access token manquant');
      return false;
    }
    return true;
  }

 /// Base URL pour l'API Mapbox (utilisé dans mapbox_service.dart)
 static const String baseUrl = 'https://api.mapbox.com';

 /// Initialise la configuration (appelé au démarrage de l'app)
  static Future<void> initialize() async {
    try {
 await dotenv.load(fileName: '.env');
      if (!isValid) {
        _logger.e('Configuration Mapbox invalide. Verifiez votre fichier .env');
 _logger.w(' Ajoutez MAPBOX_ACCESS_TOKEN dans votre fichier .env');
      } else {
 _logger.i(' Configuration Mapbox initialisée avec succès');
      }
    } catch (e) {
 _logger.e('Erreur lors du chargement de la configuration Mapbox: $e');
    }
  }

  /// Régions du Québec pour la recherche
  static const List<String> quebecRegions = [
 'Bas-Saint-Laurent',
 'Saguenay–Lac-Saint-Jean',
 'Capitale-Nationale',
 'Mauricie',
 'Estrie',
 'Montréal',
 'Outaouais',
 'Abitibi-Témiscamingue',
 'Côte-Nord',
 'Nord-du-Québec',
 'Gaspésie–Îles-de-la-Madeleine',
 'Chaudière-Appalaches',
 'Laval',
 'Lanaudière',
 'Laurentides',
 'Montérégie',
 'Centre-du-Québec',
  ];
}

