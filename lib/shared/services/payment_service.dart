/// Service de paiement international avec support multi-devises
/// Implémente Stripe pour les paiements sécurisés
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/config/app_config.dart';
import '../../core/localization/currency_service.dart';
import '../../core/localization/app_locale.dart';
import '../../shared/services/supabase_service.dart';

/// Méthodes de paiement supportées
enum PaymentMethod {
  stripe,
  paypal,
  applePay,
  googlePay,
  localCard,
  bankTransfer,
  crypto,
}

/// Statut d'un paiement
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

/// Modèle de paiement
class PaymentRequest {
  final double amount;
  final String currencyCode;
  final String reservationId;
  final PaymentMethod method;
  final Map<String, dynamic>? metadata;

  PaymentRequest({
    required this.amount,
    required this.currencyCode,
    required this.reservationId,
    required this.method,
    this.metadata,
  });
}

class PaymentService {
  static final Logger _logger = Logger();
  static PaymentService? _instance;
  final Dio _dio = Dio();
  final String _baseUrl;
  
  factory PaymentService() => _instance ??= PaymentService._internal();
  PaymentService._internal() : _baseUrl = AppConfig.supabaseUrl {
    _dio.options.baseUrl = '$_baseUrl/functions/v1';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  String? get _authToken {
    return SupabaseService.client.auth.currentSession?.accessToken;
  }

  /// Initialise le service de paiement
  Future<void> initialize() async {
    if (AppConfig.stripePublishableKey.isEmpty) {
      _logger.w('STRIPE_PUBLISHABLE_KEY non configuré dans .env');
    } else {
      _logger.i('PaymentService initialisé avec Stripe');
    }
  }

  /// Obtient les méthodes de paiement disponibles pour une région
  Future<List<PaymentMethod>> getAvailablePaymentMethods({
    required String regionCode,
  }) async {
    // En production, récupérer depuis la base de données
 // Pour l'instant, retourner les méthodes par défaut selon la région
    switch (regionCode) {
 case 'CA-QC':
 case 'CA-ON':
 case 'CA-BC':
        return [PaymentMethod.stripe, PaymentMethod.paypal, PaymentMethod.applePay];
 case 'US-CA':
 case 'US-NY':
        return [
          PaymentMethod.stripe,
          PaymentMethod.paypal,
          PaymentMethod.applePay,
          PaymentMethod.googlePay,
        ];
 case 'MX-CDMX':
        return [PaymentMethod.stripe, PaymentMethod.paypal];
 case 'BR-SP':
        return [PaymentMethod.stripe, PaymentMethod.paypal];
      default:
        return [PaymentMethod.stripe, PaymentMethod.paypal];
    }
  }

  /// Crée une intention de paiement
  Future<Map<String, dynamic>> createPaymentIntent(PaymentRequest request) async {
    try {
      // Convertir le montant si nécessaire
      final convertedAmount = await _convertAmountIfNeeded(
        amount: request.amount,
        fromCurrency: request.currencyCode,
        toCurrency: request.currencyCode,
      );

      if (request.method == PaymentMethod.stripe) {
        // Appeler l'Edge Function Stripe
        final response = await _dio.post(
          '/payments/create-intent',
          data: {
            'reservation_id': request.reservationId,
            'amount': convertedAmount,
            'currency': request.currencyCode.toUpperCase(),
            'metadata': request.metadata,
          },
          options: Options(
            headers: {
              if (_authToken != null) 'Authorization': 'Bearer $_authToken',
            },
          ),
        );

        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'payment_intent_id': data['payment_intent_id'] as String,
          'client_secret': data['client_secret'] as String,
          'amount': data['amount'] as double,
          'currency': data['currency'] as String,
          'status': 'requires_payment_method',
        };
      } else {
        // Pour les autres méthodes (PayPal, etc.), utiliser l'implémentation future
        _logger.w('Méthode de paiement ${request.method} non encore implémentée');
        throw Exception('Méthode de paiement non supportée: ${request.method}');
      }
    } catch (e) {
      _logger.e('Erreur lors de la création de l\'intention de paiement: $e');
      rethrow;
    }
  }

  /// Confirme un paiement
  /// Note: Pour Stripe, la confirmation se fait côté client avec le client_secret
  /// Cette méthode vérifie le statut du paiement
  Future<PaymentStatus> confirmPayment({
    required String paymentIntentId,
    required PaymentMethod method,
    required Map<String, dynamic> paymentData,
  }) async {
    try {
      _logger.d('Vérification du statut du paiement: $paymentIntentId');

      if (method == PaymentMethod.stripe) {
        // Pour Stripe, la confirmation se fait côté client
        // On vérifie juste le statut via l'Edge Function
        final status = await getPaymentStatus(paymentIntentId);
        return status;
      } else {
        _logger.w('Méthode de paiement ${method} non encore implémentée');
        return PaymentStatus.failed;
      }
    } catch (e) {
      _logger.e('Erreur lors de la confirmation du paiement: $e');
      return PaymentStatus.failed;
    }
  }

  /// Annule un paiement
  Future<bool> cancelPayment(String paymentIntentId) async {
    try {
 _logger.d('Annulation du paiement: $paymentIntentId');
 // En production, appeler l'API du fournisseur
      return true;
    } catch (e) {
 _logger.e('Erreur lors de l\'annulation du paiement: $e');
      return false;
    }
  }

  /// Rembourse un paiement
  Future<bool> refundPayment({
    required String paymentIntentId,
    double? amount,
  }) async {
    try {
 _logger.d('Remboursement du paiement: $paymentIntentId');
 // En production, appeler l'API du fournisseur
      return true;
    } catch (e) {
 _logger.e('Erreur lors du remboursement: $e');
      return false;
    }
  }

  /// Convertit un montant si nécessaire
  Future<double> _convertAmountIfNeeded({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    // En production, utiliser un service de conversion de devises en temps réel
    return CurrencyService.convertCurrency(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
  }

  /// Obtient le statut d'un paiement
  Future<PaymentStatus> getPaymentStatus(String paymentIntentId) async {
    try {
      _logger.d('Vérification du statut du paiement: $paymentIntentId');
      
      final response = await _dio.get(
        '/payments/status/$paymentIntentId',
        options: Options(
          headers: {
            if (_authToken != null) 'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final statusString = data['status'] as String;
      
      // Mapper le statut depuis l'Edge Function
      switch (statusString) {
        case 'completed':
          return PaymentStatus.completed;
        case 'processing':
          return PaymentStatus.processing;
        case 'pending':
          return PaymentStatus.pending;
        case 'cancelled':
          return PaymentStatus.cancelled;
        case 'failed':
          return PaymentStatus.failed;
        default:
          _logger.w('Statut de paiement inconnu: $statusString');
          return PaymentStatus.pending;
      }
    } catch (e) {
      _logger.e('Erreur lors de la récupération du statut: $e');
      return PaymentStatus.failed;
    }
  }
}
