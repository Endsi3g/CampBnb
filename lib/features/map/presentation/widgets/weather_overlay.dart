import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/monitoring/network_error_interceptor.dart';
import '../../../core/monitoring/error_monitoring_service.dart';

/// Widget pour afficher une surcouche météo sur la carte
/// Utilise l'API OpenWeatherMap (gratuite) ou une autre source météo
class WeatherOverlay extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherOverlay({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeatherOverlay> createState() => _WeatherOverlayState();
}

class _WeatherOverlayState extends State<WeatherOverlay> {
  WeatherData? _weather;
  bool _isLoading = true;
  late final Dio _dio;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    // Ajouter l'intercepteur de monitoring des erreurs réseau
    _dio.interceptors.add(NetworkErrorInterceptor());
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    // TODO: Configurer l'API météo (OpenWeatherMap, WeatherAPI, etc.)
    // Pour l'instant, retourne des données mockées

    setState(() {
      _isLoading = false;
      // Données mockées pour le Québec
      _weather = WeatherData(
        temperature: 22,
        condition: 'Ensoleille',
        iconCode: '01',
        humidity: 65,
        windSpeed: 15,
      );
    });

    // Exemple avec OpenWeatherMap (nécessite une clé API)
    /*
    try {
      final response = await _dio.get(
 'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
 'lat': widget.latitude,
 'lon': widget.longitude,
 'appid': 'YOUR_API_KEY',
 'units': 'metric',
 'lang': 'fr',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _weather = WeatherData.fromOpenWeatherMap(data);
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      _logger.e('Erreur lors du chargement de la météo: $e');
      await ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
          'component': 'weather_overlay',
          'latitude': widget.latitude,
          'longitude': widget.longitude,
        },
      );
      setState(() => _isLoading = false);
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _weather == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              WeatherData.getIconFromCode(_weather!.iconCode),
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_weather!.temperature}°C',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _weather!.condition,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Modèle pour les données météo
class WeatherData {
  final double temperature;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromOpenWeatherMap(Map<String, dynamic> data) {
    final main = data['main'] as Map<String, dynamic>;
    final weather = (data['weather'] as List).first as Map<String, dynamic>;
    final wind = data['wind'] as Map<String, dynamic>?;

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['description'] as String,
      iconCode: weather['icon'] as String,
      humidity: main['humidity'] as int,
      windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static IconData getIconFromCode(String code) {
    // Mapping des codes OpenWeatherMap vers icônes Material
    if (code.startsWith('01')) return Icons.wb_sunny; // Clear sky
    if (code.startsWith('02')) return Icons.wb_cloudy; // Few clouds
    if (code.startsWith('03') || code.startsWith('04'))
      return Icons.cloud; // Clouds
    if (code.startsWith('09') || code.startsWith('10'))
      return Icons.grain; // Rain
    if (code.startsWith('11')) return Icons.flash_on; // Thunderstorm
    if (code.startsWith('13')) return Icons.ac_unit; // Snow
    if (code.startsWith('50')) return Icons.blur_on; // Mist
    return Icons.wb_sunny;
  }
}
