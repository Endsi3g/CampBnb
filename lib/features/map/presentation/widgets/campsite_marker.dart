import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/campsite_location.dart';
import '../../../core/theme/app_colors.dart';

/// Marqueur personnalisé pour un emplacement de camping
class CampsiteMarker {
  final CampsiteLocation campsite;
  final VoidCallback? onTap;
  final Logger _logger = Logger();
  String? _annotationId;

  CampsiteMarker({required this.campsite, this.onTap});

  /// Ajoute le marqueur à la carte
  Future<void> addToMap(MapboxMap mapboxMap) async {
    try {
      // Crée l'icône du marqueur selon le type
      final icon = _getIconForType(campsite.type);

      // Crée l'annotation point
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(campsite.longitude, campsite.latitude),
        ),
        image: icon,
        iconSize: 1.0,
        iconAnchor: IconAnchor.BOTTOM,
      );

      // Ajoute le point à la carte
      // Note: L'API peut varier selon la version de mapbox_maps_flutter
      // Vérifiez la documentation pour la méthode exacte
      // final manager = await mapboxMap.annotations.createPointAnnotationManager();
      // final annotation = await manager.create(pointAnnotationOptions);
      // _annotationId = annotation.id;

      // Pour l'instant, utilisez une implémentation alternative ou attendez que la carte soit prête
      _logger.w('Ajout de marqueur - API Mapbox à adapter selon la version');
    } catch (e) {
      _logger.e('Erreur lors de l\'ajout du marqueur: $e');
    }
  }

  /// Retire le marqueur de la carte
  Future<void> removeFromMap(MapboxMap mapboxMap) async {
    if (_annotationId == null) return;

    try {
      final manager = await mapboxMap.annotations
          .createPointAnnotationManager();
      await manager.delete([_annotationId!]);
      _annotationId = null;
    } catch (e) {
      _logger.e('Erreur lors de la suppression du marqueur: $e');
    }
  }

  /// Retourne l'icône appropriée selon le type d'emplacement
  String _getIconForType(CampsiteType type) {
    // Ces icônes doivent être ajoutées comme assets ou générées dynamiquement
    switch (type) {
      case CampsiteType.tent:
        return 'tent_icon';
      case CampsiteType.rv:
        return 'rv_icon';
      case CampsiteType.cabin:
        return 'cabin_icon';
      case CampsiteType.wild:
        return 'wild_icon';
      case CampsiteType.lake:
        return 'lake_icon';
      case CampsiteType.forest:
        return 'forest_icon';
      case CampsiteType.beach:
        return 'beach_icon';
      case CampsiteType.mountain:
        return 'mountain_icon';
      default:
        return 'default_icon';
    }
  }
}

/// Widget pour créer une icône de marqueur personnalisée
class MarkerIconBuilder {
  /// Crée une icône SVG personnalisée pour un type d'emplacement
  static Widget buildIcon(CampsiteType type, {double size = 40}) {
    final color = _getColorForType(type);
    final iconData = _getIconDataForType(type);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(iconData, color: Colors.white, size: size * 0.6),
    );
  }

  static Color _getColorForType(CampsiteType type) {
    switch (type) {
      case CampsiteType.tent:
        return AppColors.primary;
      case CampsiteType.rv:
        return AppColors.secondary;
      case CampsiteType.cabin:
        return const Color(0xFF8B4513); // Marron
      case CampsiteType.wild:
        return const Color(0xFF4A4A4A); // Gris foncé
      case CampsiteType.lake:
        return const Color(0xFF1E90FF); // Bleu
      case CampsiteType.forest:
        return AppColors.primary;
      case CampsiteType.beach:
        return const Color(0xFFFFD700); // Or
      case CampsiteType.mountain:
        return const Color(0xFF696969); // Gris
      default:
        return AppColors.primary;
    }
  }

  static IconData _getIconDataForType(CampsiteType type) {
    switch (type) {
      case CampsiteType.tent:
        return Icons.camping;
      case CampsiteType.rv:
        return Icons.rv_hookup;
      case CampsiteType.cabin:
        return Icons.cabin;
      case CampsiteType.wild:
        return Icons.forest;
      case CampsiteType.lake:
        return Icons.water;
      case CampsiteType.forest:
        return Icons.park;
      case CampsiteType.beach:
        return Icons.beach_access;
      case CampsiteType.mountain:
        return Icons.landscape;
      default:
        return Icons.place;
    }
  }
}
