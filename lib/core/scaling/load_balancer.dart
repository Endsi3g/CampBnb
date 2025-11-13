/// Service de load balancing pour distribuer les requêtes
import 'package:logger/logger.dart';
import 'dart:math';

class LoadBalancer {
  static final Logger _logger = Logger();

  final List<String> _endpoints;
  final LoadBalancingStrategy _strategy;
  int _currentIndex = 0;
  final Map<String, int> _requestCounts = {};

  LoadBalancer({
    required List<String> endpoints,
    LoadBalancingStrategy strategy = LoadBalancingStrategy.roundRobin,
  }) : _endpoints = endpoints,
       _strategy = strategy {
    for (final endpoint in endpoints) {
      _requestCounts[endpoint] = 0;
    }
  }

  /// Obtient le prochain endpoint selon la stratégie
  String getNextEndpoint() {
    switch (_strategy) {
      case LoadBalancingStrategy.roundRobin:
        return _getRoundRobinEndpoint();
      case LoadBalancingStrategy.random:
        return _getRandomEndpoint();
      case LoadBalancingStrategy.leastConnections:
        return _getLeastConnectionsEndpoint();
      default:
        return _getRoundRobinEndpoint();
    }
  }

  String _getRoundRobinEndpoint() {
    final endpoint = _endpoints[_currentIndex];
    _currentIndex = (_currentIndex + 1) % _endpoints.length;
    return endpoint;
  }

  String _getRandomEndpoint() {
    final random = Random();
    return _endpoints[random.nextInt(_endpoints.length)];
  }

  String _getLeastConnectionsEndpoint() {
    String leastLoaded = _endpoints.first;
    int minCount = _requestCounts[leastLoaded] ?? 0;

    for (final endpoint in _endpoints) {
      final count = _requestCounts[endpoint] ?? 0;
      if (count < minCount) {
        minCount = count;
        leastLoaded = endpoint;
      }
    }

    _requestCounts[leastLoaded] = (_requestCounts[leastLoaded] ?? 0) + 1;
    return leastLoaded;
  }

  /// Marque une requête comme terminée
  void markRequestComplete(String endpoint) {
    final count = _requestCounts[endpoint] ?? 0;
    if (count > 0) {
      _requestCounts[endpoint] = count - 1;
    }
  }

  /// Ajoute un endpoint
  void addEndpoint(String endpoint) {
    if (!_endpoints.contains(endpoint)) {
      _endpoints.add(endpoint);
      _requestCounts[endpoint] = 0;
    }
  }

  /// Retire un endpoint
  void removeEndpoint(String endpoint) {
    _endpoints.remove(endpoint);
    _requestCounts.remove(endpoint);
  }
}

enum LoadBalancingStrategy { roundRobin, random, leastConnections }
