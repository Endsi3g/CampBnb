/// Script de test pour la capture d'erreurs en staging
/// À exécuter manuellement ou via un script CI/CD pour vérifier que Sentry fonctionne
import 'dart:io';
import 'package:campbnb_quebec/core/monitoring/error_monitoring_service.dart';

void main() async {
  print('🧪 Test de capture d\'erreurs en staging...\n');

  // Initialiser le service de monitoring
  final sentryDsn = Platform.environment['SENTRY_DSN'] ?? '';
  if (sentryDsn.isEmpty) {
    print('❌ SENTRY_DSN non configuré. Utilisez: export SENTRY_DSN=your-dsn');
    exit(1);
  }

  await ErrorMonitoringService.initialize(
    sentryDsn: sentryDsn,
    enableSentry: true,
    enableTalker: true,
  );

  print('✅ Service de monitoring initialisé\n');

  // Test 1: Exception simple
  print('Test 1: Capture d\'une exception simple...');
  try {
    await ErrorMonitoringService().captureException(
      Exception('Test exception - Staging'),
      context: {
        'test': true,
        'environment': 'staging',
        'test_type': 'simple_exception',
      },
    );
    print('✅ Exception capturée\n');
  } catch (e) {
    print('❌ Erreur: $e\n');
  }

  // Test 2: Erreur réseau
  print('Test 2: Capture d\'une erreur réseau...');
  try {
    await ErrorMonitoringService().captureNetworkError(
      url: 'https://api.example.com/test',
      statusCode: 500,
      method: 'GET',
      exception: Exception('Network error - Staging'),
    );
    print('✅ Erreur réseau capturée\n');
  } catch (e) {
    print('❌ Erreur: $e\n');
  }

  // Test 3: Problème de performance
  print('Test 3: Capture d\'un problème de performance...');
  try {
    await ErrorMonitoringService().capturePerformanceIssue(
      operation: 'test_operation_staging',
      duration: const Duration(seconds: 5),
      context: 'Test performance issue in staging',
    );
    print('✅ Problème de performance capturé\n');
  } catch (e) {
    print('❌ Erreur: $e\n');
  }

  // Test 4: Breadcrumb
  print('Test 4: Ajout d\'un breadcrumb...');
  try {
    ErrorMonitoringService().addBreadcrumb(
      message: 'Test breadcrumb - Staging',
      category: 'test',
      data: {'test': true, 'environment': 'staging'},
    );
    print('✅ Breadcrumb ajouté\n');
  } catch (e) {
    print('❌ Erreur: $e\n');
  }

  // Test 5: Tag personnalisé
  print('Test 5: Ajout d\'un tag personnalisé...');
  try {
    ErrorMonitoringService().addTag('test_environment', 'staging');
    print('✅ Tag ajouté\n');
  } catch (e) {
    print('❌ Erreur: $e\n');
  }

  // Test 6: Contexte personnalisé
  print('Test 6: Ajout de contexte personnalisé...');
  try {
    ErrorMonitoringService().addContext(
      'test_context',
      {
        'environment': 'staging',
        'test_run': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      },
    );
    print('✅ Contexte ajouté\n');
  } catch (e) {
    print('❌ Erreur: $e\n');
  }

  print('✅ Tous les tests sont terminés!');
  print('📊 Vérifiez le dashboard Sentry pour voir les erreurs capturées.');
  print('🔗 https://sentry.io/organizations/your-org/issues/');
}

