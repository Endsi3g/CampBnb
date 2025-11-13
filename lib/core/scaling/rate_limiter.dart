/// Service de rate limiting pour protéger les APIs
import 'package:logger/logger.dart';
import 'dart:collection';

class RateLimiter {
  static final Logger _logger = Logger();
  
  final int maxRequests;
  final Duration window;
  final Map<String, Queue<DateTime>> _requestHistory = {};

  RateLimiter({
    required this.maxRequests,
    required this.window,
  });

  /// Vérifie si une requête peut être effectuée
  bool canMakeRequest(String identifier) {
    final now = DateTime.now();
    final history = _requestHistory.putIfAbsent(identifier, () => Queue<DateTime>());

    // Nettoyer les requêtes expirées
    while (history.isNotEmpty && 
           now.difference(history.first) > window) {
      history.removeFirst();
    }

    // Vérifier la limite
    if (history.length >= maxRequests) {
 _logger.w('Rate limit atteint pour $identifier');
      return false;
    }

    // Enregistrer la requête
    history.add(now);
    return true;
  }

 /// Réinitialise l'historique pour un identifiant
  void reset(String identifier) {
    _requestHistory.remove(identifier);
  }

  /// Réinitialise tout
  void resetAll() {
    _requestHistory.clear();
  }

  /// Obtient le nombre de requêtes restantes
  int getRemainingRequests(String identifier) {
    final history = _requestHistory[identifier];
    if (history == null) return maxRequests;

    final now = DateTime.now();
    final validRequests = history.where(
      (timestamp) => now.difference(timestamp) <= window,
    ).length;

    return maxRequests - validRequests;
  }
}


