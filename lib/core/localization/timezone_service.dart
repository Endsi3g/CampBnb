/// Service pour gérer les fuseaux horaires
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:logger/logger.dart';

class TimezoneService {
  static final Logger _logger = Logger();
  static bool _initialized = false;

  /// Initialise le service de fuseaux horaires
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
      _initialized = true;
      _logger.i(' TimezoneService initialisé');
    } catch (e) {
      _logger.e(' Erreur lors de l\'initialisation de TimezoneService: $e');
      rethrow;
    }
  }

  /// Convertit une date/heure vers un fuseau horaire spécifique
  static tz.TZDateTime convertToTimezone(
    DateTime dateTime,
    String timezoneName,
  ) {
    try {
      final location = tz.getLocation(timezoneName);
      return tz.TZDateTime.from(dateTime, location);
    } catch (e) {
      _logger.w('Fuseau horaire $timezoneName non trouvé, utilisation UTC');
      return tz.TZDateTime.from(dateTime, tz.UTC);
    }
  }

  /// Obtient la date/heure actuelle dans un fuseau horaire spécifique
  static tz.TZDateTime nowInTimezone(String timezoneName) {
    try {
      final location = tz.getLocation(timezoneName);
      return tz.TZDateTime.now(location);
    } catch (e) {
      _logger.w('Fuseau horaire $timezoneName non trouvé, utilisation UTC');
      return tz.TZDateTime.now(tz.UTC);
    }
  }

  /// Convertit une date/heure UTC vers le fuseau horaire local de l'utilisateur
  static DateTime toLocal(DateTime utcDateTime, String timezoneName) {
    try {
      final location = tz.getLocation(timezoneName);
      final tzDateTime = tz.TZDateTime.from(utcDateTime, tz.UTC);
      return tzDateTime.toLocal();
    } catch (e) {
      return utcDateTime.toLocal();
    }
  }

  /// Convertit une date/heure locale vers UTC
  static DateTime toUtc(DateTime localDateTime, String timezoneName) {
    try {
      final location = tz.getLocation(timezoneName);
      final tzDateTime = tz.TZDateTime.from(localDateTime, location);
      return tzDateTime.toUtc();
    } catch (e) {
      return localDateTime.toUtc();
    }
  }

  /// Obtient le fuseau horaire par défaut pour un pays
  static String getTimezoneForCountry(String countryCode) {
    final timezoneMap = {
      'US': 'America/New_York', // Par défaut, peut être ajusté par région
      'CA': 'America/Toronto',
      'MX': 'America/Mexico_City',
      'BR': 'America/Sao_Paulo',
      'AR': 'America/Argentina/Buenos_Aires',
      'CL': 'America/Santiago',
      'CO': 'America/Bogota',
      'PE': 'America/Lima',
      'FR': 'Europe/Paris',
      'ES': 'Europe/Madrid',
      'IT': 'Europe/Rome',
      'DE': 'Europe/Berlin',
      'GB': 'Europe/London',
      'JP': 'Asia/Tokyo',
      'CN': 'Asia/Shanghai',
      'KR': 'Asia/Seoul',
      'IN': 'Asia/Kolkata',
      'AU': 'Australia/Sydney',
      'NZ': 'Pacific/Auckland',
    };

    return timezoneMap[countryCode] ?? 'UTC';
  }

  /// Liste des fuseaux horaires principaux par région
  static const Map<String, List<String>> timezonesByRegion = {
    'North America': [
      'America/New_York',
      'America/Chicago',
      'America/Denver',
      'America/Los_Angeles',
      'America/Toronto',
      'America/Vancouver',
      'America/Mexico_City',
    ],
    'South America': [
      'America/Sao_Paulo',
      'America/Argentina/Buenos_Aires',
      'America/Santiago',
      'America/Bogota',
      'America/Lima',
    ],
    'Europe': [
      'Europe/London',
      'Europe/Paris',
      'Europe/Berlin',
      'Europe/Rome',
      'Europe/Madrid',
      'Europe/Amsterdam',
    ],
    'Asia': [
      'Asia/Tokyo',
      'Asia/Shanghai',
      'Asia/Seoul',
      'Asia/Kolkata',
      'Asia/Dubai',
      'Asia/Singapore',
    ],
    'Oceania': ['Australia/Sydney', 'Australia/Melbourne', 'Pacific/Auckland'],
  };
}
