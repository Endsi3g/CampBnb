/// Service de conversion de devises en temps réel
/// Utilise exchangerate-api.com (gratuit jusqu'à 1500 requêtes/mois)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_service.dart';

class CurrencyExchangeService {
  static final Logger _logger = Logger();
  static CurrencyExchangeService? _instance;
  
  factory CurrencyExchangeService() => _instance ??= CurrencyExchangeService._internal();
  CurrencyExchangeService._internal();

  // API gratuite : exchangerate-api.com
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static const Duration _cacheDuration = Duration(hours: 1);
  
  Map<String, Map<String, double>> _exchangeRates = {};
  DateTime? _lastUpdate;

  /// Initialise le service
  Future<void> initialize() async {
    await _loadCachedRates();
    if (_exchangeRates.isEmpty || _shouldRefreshCache()) {
      await refreshRates();
    }
  }

  /// Rafraîchit les taux de change depuis l'API
  Future<void> refreshRates() async {
    try {
      _logger.d('🔄 Actualisation des taux de change...');
      
      // Récupérer les taux depuis USD (devise de référence)
      final response = await http.get(
        Uri.parse('$_baseUrl/USD'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        
        // Convertir en Map<String, double>
        _exchangeRates['USD'] = rates.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );

        _lastUpdate = DateTime.now();
        await _saveCachedRates();
        
        _logger.i('✅ Taux de change actualisés avec succès');
      } else {
        _logger.w('⚠️ Erreur lors de la récupération des taux: ${response.statusCode}');
        // Utiliser les taux en cache si disponibles
        if (_exchangeRates.isEmpty) {
          _loadFallbackRates();
        }
      }
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'actualisation des taux: $e');
      // Utiliser les taux en cache ou fallback
      if (_exchangeRates.isEmpty) {
        _loadFallbackRates();
      }
    }
  }

  /// Convertit un montant d'une devise à une autre
  Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    // S'assurer que les taux sont à jour
    if (_shouldRefreshCache()) {
      await refreshRates();
    }

    // Si pas de taux disponibles, utiliser le service statique
    if (_exchangeRates.isEmpty || _exchangeRates['USD'] == null) {
      _logger.w('⚠️ Utilisation des taux de change statiques');
      return CurrencyService.convertCurrency(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    }

    final usdRates = _exchangeRates['USD']!;

    // Convertir via USD
    double usdAmount;
    if (fromCurrency == 'USD') {
      usdAmount = amount;
    } else {
      final fromRate = usdRates[fromCurrency];
      if (fromRate == null) {
        _logger.w('⚠️ Taux non trouvé pour $fromCurrency, utilisation du service statique');
        return CurrencyService.convertCurrency(
          amount: amount,
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
        );
      }
      usdAmount = amount / fromRate;
    }

    // Convertir vers la devise cible
    if (toCurrency == 'USD') {
      return usdAmount;
    }

    final toRate = usdRates[toCurrency];
    if (toRate == null) {
      _logger.w('⚠️ Taux non trouvé pour $toCurrency, utilisation du service statique');
      return CurrencyService.convertCurrency(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    }

    return usdAmount * toRate;
  }

  /// Obtient le taux de change actuel
  double? getExchangeRate(String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return 1.0;

    final usdRates = _exchangeRates['USD'];
    if (usdRates == null) return null;

    final fromRate = fromCurrency == 'USD' ? 1.0 : usdRates[fromCurrency];
    final toRate = toCurrency == 'USD' ? 1.0 : usdRates[toCurrency];

    if (fromRate == null || toRate == null) return null;

    return toRate / fromRate;
  }

  /// Vérifie si le cache doit être rafraîchi
  bool _shouldRefreshCache() {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > _cacheDuration;
  }

  /// Charge les taux depuis le cache local
  Future<void> _loadCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('currency_exchange_rates');
      final lastUpdateStr = prefs.getString('currency_exchange_last_update');

      if (cachedJson != null && lastUpdateStr != null) {
        final lastUpdate = DateTime.parse(lastUpdateStr);
        if (DateTime.now().difference(lastUpdate) < _cacheDuration) {
          final data = json.decode(cachedJson) as Map<String, dynamic>;
          _exchangeRates = data.map(
            (key, value) => MapEntry(
              key,
              (value as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              ),
            ),
          );
          _lastUpdate = lastUpdate;
          _logger.d('✅ Taux de change chargés depuis le cache');
        }
      }
    } catch (e) {
      _logger.e('❌ Erreur lors du chargement du cache: $e');
    }
  }

  /// Sauvegarde les taux dans le cache local
  Future<void> _saveCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency_exchange_rates', json.encode(_exchangeRates));
      await prefs.setString(
        'currency_exchange_last_update',
        _lastUpdate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      _logger.e('❌ Erreur lors de la sauvegarde du cache: $e');
    }
  }

  /// Charge les taux de fallback (statiques)
  void _loadFallbackRates() {
    _logger.w('⚠️ Utilisation des taux de change statiques (fallback)');
    // Les taux statiques sont gérés par CurrencyService
  }

  /// Obtient la date de dernière mise à jour
  DateTime? get lastUpdate => _lastUpdate;
}

