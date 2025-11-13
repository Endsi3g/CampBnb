/// Configuration des endpoints CDN par région
import 'package:logger/logger.dart';

class CDNConfig {
  static final Logger _logger = Logger();

  // Configuration par environnement
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  // URLs CDN par région - Configuration Cloudflare
  // Remplacez 'campbnb' par votre domaine Cloudflare
  // Pour configurer: Cloudflare Dashboard > Workers & Pages > Create Application
  
  static const Map<String, String> _productionCDNUrls = {
    // Cloudflare Workers/Pages avec routing par région
    'us-east': 'https://cdn-us-east.campbnb.pages.dev', // ou votre domaine custom
    'us-west': 'https://cdn-us-west.campbnb.pages.dev',
    'eu-west': 'https://cdn-eu-west.campbnb.pages.dev',
    'asia-pacific': 'https://cdn-asia.campbnb.pages.dev',
    'south-america': 'https://cdn-sa.campbnb.pages.dev',
    
    // Alternative: Utiliser un seul CDN avec routing intelligent
    // 'us-east': 'https://cdn.campbnb.com/us-east',
    // 'us-west': 'https://cdn.campbnb.com/us-west',
    // etc.
  };

  // URLs de développement/staging
  static const Map<String, String> _developmentCDNUrls = {
    'us-east': 'https://cdn-dev-us-east.campbnb.pages.dev',
    'us-west': 'https://cdn-dev-us-west.campbnb.pages.dev',
    'eu-west': 'https://cdn-dev-eu-west.campbnb.pages.dev',
    'asia-pacific': 'https://cdn-dev-asia.campbnb.pages.dev',
    'south-america': 'https://cdn-dev-sa.campbnb.pages.dev',
  };

  // Fallback vers Cloudflare R2 ou autre CDN public
  // Cloudflare R2: https://pub-<account-id>.r2.dev
  static const String _fallbackCDN = 'https://cdn.campbnb.com';

  /// Obtient l'URL CDN selon l'environnement
  static String getCdnUrl(String region) {
    final cdnUrls = _isProduction ? _productionCDNUrls : _developmentCDNUrls;
    return cdnUrls[region] ?? _fallbackCDN;
  }

  /// Obtient l'URL CDN pour une région géographique
  static String getCdnUrlForRegion(String regionCode) {
    // Mapper les codes de région aux CDN
    String cdnRegion;
    
    if (regionCode.startsWith('US-') || regionCode.startsWith('CA-')) {
      // Utiliser le CDN le plus proche selon la région
      if (regionCode.contains('CA') || regionCode.contains('NY') || 
          regionCode.contains('ON') || regionCode.contains('QC')) {
        cdnRegion = 'us-east';
      } else {
        cdnRegion = 'us-west';
      }
    } else if (regionCode.startsWith('FR-') || 
               regionCode.startsWith('ES-') || 
               regionCode.startsWith('DE-') ||
               regionCode.startsWith('IT-') ||
               regionCode.startsWith('GB-')) {
      cdnRegion = 'eu-west';
    } else if (regionCode.startsWith('JP-') || 
               regionCode.startsWith('CN-') || 
               regionCode.startsWith('KR-') ||
               regionCode.startsWith('IN-') ||
               regionCode.startsWith('AU-') ||
               regionCode.startsWith('NZ-')) {
      cdnRegion = 'asia-pacific';
    } else if (regionCode.startsWith('MX-') || 
               regionCode.startsWith('BR-') || 
               regionCode.startsWith('AR-') ||
               regionCode.startsWith('CL-') ||
               regionCode.startsWith('CO-') ||
               regionCode.startsWith('PE-')) {
      cdnRegion = 'south-america';
    } else {
      cdnRegion = 'us-east'; // Par défaut
    }

    return getCdnUrl(cdnRegion);
  }

  /// Valide la configuration CDN
  static bool validateConfig() {
    final errors = <String>[];

    if (_isProduction) {
      for (final entry in _productionCDNUrls.entries) {
        if (!entry.value.startsWith('https://')) {
          errors.add('CDN URL pour ${entry.key} doit utiliser HTTPS');
        }
      }
    }

    if (errors.isNotEmpty) {
      _logger.e('❌ Erreurs de configuration CDN: ${errors.join(', ')}');
      return false;
    }

    return true;
  }

  /// Obtient tous les endpoints CDN configurés
  static Map<String, String> getAllEndpoints() {
    return _isProduction ? _productionCDNUrls : _developmentCDNUrls;
  }

  /// Initialise et valide la configuration CDN
  /// À appeler au démarrage de l'application
  static Future<void> initialize() async {
    if (!validateConfig()) {
      _logger.w('⚠️  Configuration CDN invalide, utilisation du fallback');
    } else {
      _logger.i('✅ Configuration CDN validée');
    }
  }
}

