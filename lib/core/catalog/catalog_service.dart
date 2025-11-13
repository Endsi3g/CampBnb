/// Service pour gérer l'expansion des catalogues par région
import 'package:logger/logger.dart';
import '../localization/app_locale.dart';

class CatalogService {
  static final Logger _logger = Logger();

  /// Obtient les catégories disponibles pour une région
  Future<List<CatalogCategory>> getCategoriesForRegion({
    required String regionCode,
    String? languageCode,
  }) async {
    try {
      // En production, récupérer depuis la base de données
 // Pour l'instant, retourner les catégories par défaut
      return _getDefaultCategories(regionCode, languageCode);
    } catch (e) {
 _logger.e('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  List<CatalogCategory> _getDefaultCategories(String regionCode, String? languageCode) {
 final lang = languageCode ?? 'en';
    
    return [
      CatalogCategory(
 code: 'tent',
 name: _getCategoryName('tent', lang),
 icon: 'tent',
        isAvailable: true,
      ),
      CatalogCategory(
 code: 'rv',
 name: _getCategoryName('rv', lang),
 icon: 'rv',
        isAvailable: true,
      ),
      CatalogCategory(
 code: 'cabin',
 name: _getCategoryName('cabin', lang),
 icon: 'cabin',
        isAvailable: true,
      ),
      CatalogCategory(
 code: 'yurt',
 name: _getCategoryName('yurt', lang),
 icon: 'yurt',
        isAvailable: true,
      ),
      CatalogCategory(
 code: 'treehouse',
 name: _getCategoryName('treehouse', lang),
 icon: 'treehouse',
        isAvailable: true,
      ),
    ];
  }

  String _getCategoryName(String code, String lang) {
    const names = {
 'tent': {
 'en': 'Tent',
 'fr': 'Tente',
 'es': 'Tienda',
 'pt': 'Barraca',
 'de': 'Zelt',
 'it': 'Tenda',
 'ja': 'テント',
 'zh': '帐篷',
 'ko': '텐트',
      },
 'rv': {
 'en': 'RV',
 'fr': 'VR',
 'es': 'Autocaravana',
 'pt': 'Motorhome',
 'de': 'Wohnmobil',
 'it': 'Camper',
 'ja': 'RV',
 'zh': '房车',
 'ko': 'RV',
      },
 'cabin': {
 'en': 'Cabin',
 'fr': 'Chalet',
 'es': 'Cabaña',
 'pt': 'Cabana',
 'de': 'Hütte',
 'it': 'Capanna',
 'ja': 'キャビン',
 'zh': '小屋',
 'ko': '오두막',
      },
    };

    return names[code]?[lang] ?? code;
  }

  /// Obtient les expériences locales pour une région
  Future<List<LocalExperience>> getLocalExperiencesForRegion({
    required String regionCode,
    String? category,
  }) async {
    try {
      // En production, récupérer depuis la base de données
      return [];
    } catch (e) {
 _logger.e('Erreur lors de la récupération des expériences locales: $e');
      return [];
    }
  }

  /// Ajoute une nouvelle catégorie pour une région
  Future<bool> addCategoryForRegion({
    required String regionCode,
    required CatalogCategory category,
  }) async {
    try {
      // En production, insérer dans la base de données
 _logger.d('Ajout de la catégorie ${category.code} pour la région $regionCode');
      return true;
    } catch (e) {
 _logger.e('Erreur lors de l\'ajout de la catégorie: $e');
      return false;
    }
  }
}

class CatalogCategory {
  final String code;
  final String name;
  final String icon;
  final bool isAvailable;

  CatalogCategory({
    required this.code,
    required this.name,
    required this.icon,
    this.isAvailable = true,
  });
}

class LocalExperience {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  LocalExperience({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });
}


