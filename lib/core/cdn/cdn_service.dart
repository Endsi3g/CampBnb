/// Service CDN pour optimiser la distribution des assets
import 'package:logger/logger.dart';
import 'cdn_config.dart';

class CDNService {
  static final Logger _logger = Logger();

  /// Obtient l'URL CDN optimale pour une région
  static String getCdnUrlForRegion(String regionCode) {
    return CDNConfig.getCdnUrlForRegion(regionCode);
  }

  /// Obtient l'URL optimisée d'une image
  static String getOptimizedImageUrl({
    required String imagePath,
    required String regionCode,
    int? width,
    int? height,
    String? format,
  }) {
    final cdnUrl = getCdnUrlForRegion(regionCode);
    final params = <String>[];

    if (width != null) params.add('w=$width');
    if (height != null) params.add('h=$height');
    if (format != null) params.add('f=$format');

    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$cdnUrl/images/$imagePath$queryString';
  }

  /// Obtient l'URL d'un asset statique
  static String getAssetUrl({
    required String assetPath,
    required String regionCode,
  }) {
    final cdnUrl = getCdnUrlForRegion(regionCode);
    return '$cdnUrl/assets/$assetPath';
  }

  /// Précharge des assets pour une région
  static Future<void> preloadAssets({
    required List<String> assetPaths,
    required String regionCode,
  }) async {
    final cdnUrl = getCdnUrlForRegion(regionCode);
    _logger.d('Préchargement de ${assetPaths.length} assets depuis $cdnUrl');

    // En production, utiliser un service de préchargement
    // Pour l'instant, juste logger
    for (final path in assetPaths) {
      _logger.d('Préchargement: $path');
    }
  }
}
