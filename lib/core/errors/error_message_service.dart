/// Service centralisé pour la gestion des messages d'erreur utilisateur
/// Fournit des messages d'erreur cohérents et traduits pour l'utilisateur final
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Service de gestion des messages d'erreur
class ErrorMessageService {
  static final Logger _logger = Logger();

  ErrorMessageService._();
  static final ErrorMessageService instance = ErrorMessageService._();

  /// Convertit une exception en message d'erreur utilisateur
  String getUserMessage(dynamic error, {String? defaultMessage}) {
    try {
      // Erreur réseau
      if (error is DioException) {
        return _handleDioError(error);
      }

      // Exception standard
      if (error is Exception) {
        return _handleException(error);
      }

      // String
      if (error is String) {
        return error;
      }

      // Par défaut
      return defaultMessage ??
          'Une erreur inattendue s\'est produite. Veuillez réessayer.';
    } catch (e) {
      _logger.e('Erreur lors de la conversion du message d\'erreur: $e');
      return defaultMessage ??
          'Une erreur inattendue s\'est produite. Veuillez réessayer.';
    }
  }

  /// Gère les erreurs Dio (réseau)
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Le délai d\'attente a expiré. Vérifiez votre connexion internet et réessayez.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          return _handleHttpStatusCode(statusCode, error.response?.data);
        }
        return 'Erreur lors de la communication avec le serveur.';

      case DioExceptionType.cancel:
        return 'La requête a été annulée.';

      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';

      case DioExceptionType.badCertificate:
        return 'Erreur de certificat de sécurité. Veuillez contacter le support.';

      case DioExceptionType.unknown:
      default:
        return 'Erreur de connexion. Veuillez réessayer.';
    }
  }

  /// Gère les codes de statut HTTP
  String _handleHttpStatusCode(int statusCode, dynamic responseData) {
    // Essayer d'extraire le message d'erreur du serveur
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage =
          responseData['error'] as String? ??
          responseData['message'] as String?;
    }

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    // Messages par défaut selon le code HTTP
    switch (statusCode) {
      case 400:
        return 'Requête invalide. Vérifiez les informations saisies.';
      case 401:
        return 'Vous devez être connecté pour effectuer cette action.';
      case 403:
        return 'Vous n\'avez pas les permissions nécessaires.';
      case 404:
        return 'Ressource introuvable.';
      case 409:
        return 'Conflit: cette ressource existe déjà ou a été modifiée.';
      case 422:
        return 'Les données fournies sont invalides.';
      case 429:
        return 'Trop de requêtes. Veuillez patienter quelques instants.';
      case 500:
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      case 502:
      case 503:
      case 504:
        return 'Service temporairement indisponible. Veuillez réessayer plus tard.';
      default:
        return 'Erreur serveur (code $statusCode). Veuillez réessayer.';
    }
  }

  /// Gère les exceptions standard
  String _handleException(Exception error) {
    final errorMessage = error.toString().toLowerCase();

    // Erreurs d'authentification
    if (errorMessage.contains('auth') ||
        errorMessage.contains('authentification')) {
      return 'Erreur d\'authentification. Veuillez vous reconnecter.';
    }

    // Erreurs de validation
    if (errorMessage.contains('validation') ||
        errorMessage.contains('invalid')) {
      return 'Les données fournies sont invalides.';
    }

    // Erreurs de réseau
    if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }

    // Erreurs de timeout
    if (errorMessage.contains('timeout')) {
      return 'Le délai d\'attente a expiré. Veuillez réessayer.';
    }

    // Erreurs de paiement
    if (errorMessage.contains('payment') || errorMessage.contains('stripe')) {
      return 'Erreur de paiement. Vérifiez vos informations de paiement.';
    }

    // Message générique
    return 'Une erreur s\'est produite: ${error.toString()}';
  }

  /// Messages d'erreur spécifiques par contexte
  static const Map<String, String> contextMessages = {
    'login': 'Erreur lors de la connexion. Vérifiez vos identifiants.',
    'signup': 'Erreur lors de l\'inscription. Veuillez réessayer.',
    'listing_create': 'Erreur lors de la création de l\'annonce.',
    'listing_update': 'Erreur lors de la mise à jour de l\'annonce.',
    'reservation_create': 'Erreur lors de la création de la réservation.',
    'reservation_cancel': 'Erreur lors de l\'annulation de la réservation.',
    'payment': 'Erreur lors du traitement du paiement.',
    'upload': 'Erreur lors du téléchargement de l\'image.',
    'profile_update': 'Erreur lors de la mise à jour du profil.',
  };

  /// Obtient un message d'erreur pour un contexte spécifique
  String getContextMessage(String context, {String? customMessage}) {
    return customMessage ??
        contextMessages[context] ??
        'Une erreur s\'est produite. Veuillez réessayer.';
  }
}
