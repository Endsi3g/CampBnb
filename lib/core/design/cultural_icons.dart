/// Gestion des icônes adaptées par culture
import 'package:flutter/material.dart';

class CulturalIcons {
  /// Obtient l'icône appropriée selon la culture
  /// Certaines cultures préfèrent des styles d'icônes différents
  static IconData getIconForCulture({
    required String iconName,
    required String? countryCode,
  }) {
    // Pour l'instant, on utilise les icônes Material par défaut
    // Mais on peut adapter selon la culture si nécessaire
    switch (iconName) {
      case 'camping':
        return Icons.camping;
      case 'location':
        return Icons.location_on;
      case 'calendar':
        return Icons.calendar_today;
      case 'person':
        return Icons.person;
      case 'search':
        return Icons.search;
      case 'filter':
        return Icons.filter_list;
      case 'favorite':
        return Icons.favorite;
      case 'share':
        return Icons.share;
      case 'message':
        return Icons.message;
      case 'settings':
        return Icons.settings;
      case 'payment':
        return Icons.payment;
      case 'star':
        return Icons.star;
      case 'home':
        return Icons.home;
      case 'map':
        return Icons.map;
      default:
        return Icons.help_outline;
    }
  }

  /// Obtient l'icône de drapeau pour un pays
  static String getFlagEmoji(String countryCode) {
    const flags = {
      'CA': '',
      'US': '',
      'FR': '',
      'ES': '',
      'MX': '',
      'BR': '',
      'AR': '',
      'CL': '',
      'CO': '',
      'PE': '',
      'JP': '',
      'CN': '',
      'KR': '',
      'IN': '',
      'AU': '',
      'NZ': '',
      'GB': '',
      'DE': '',
      'IT': '',
    };
    return flags[countryCode] ?? '';
  }
}
