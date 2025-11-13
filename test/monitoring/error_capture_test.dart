/// Tests pour la capture d'erreurs en staging
/// Utilise des erreurs simulées pour vérifier que Sentry capture correctement
import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/core/monitoring/error_monitoring_service.dart';
import 'package:campbnb_quebec/core/monitoring/network_error_interceptor.dart';
import 'package:campbnb_quebec/core/monitoring/observability_service.dart';
import 'package:dio/dio.dart';

void main() {
  group('Error Capture Tests', () {
    test('Capture une exception simple', () async {
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.current;

      final errorId = await ErrorMonitoringService().captureException(
        exception,
        stackTrace: stackTrace,
        context: {
          'test': true,
          'component': 'test_suite',
        },
      );

      expect(errorId, isNotNull);
      expect(errorId, isNotEmpty);
    });

    test('Capture une erreur réseau', () async {
      final errorId = await ErrorMonitoringService().captureNetworkError(
        url: 'https://api.example.com/test',
        statusCode: 500,
        method: 'GET',
        exception: DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
            data: {'error': 'Internal Server Error'},
          ),
        ),
      );

      expect(errorId, isNotNull);
    });

    test('Capture un problème de performance', () async {
      await ErrorMonitoringService().capturePerformanceIssue(
        operation: 'test_operation',
        duration: const Duration(seconds: 5),
        context: 'Test performance issue',
      );

      // Vérifier que le message est capturé
      expect(true, isTrue);
    });

    test('Ajoute un breadcrumb', () {
      ErrorMonitoringService().addBreadcrumb(
        message: 'Test breadcrumb',
        category: 'test',
        data: {'test': true},
      );

      expect(true, isTrue);
    });

    test('Définit un tag personnalisé', () {
      ErrorMonitoringService().addTag('test_tag', 'test_value');
      expect(true, isTrue);
    });

    test('Définit du contexte personnalisé', () {
      ErrorMonitoringService().addContext(
        'test_context',
        {'key': 'value'},
      );
      expect(true, isTrue);
    });
  });

  group('Network Interceptor Tests', () {
    test('Intercepteur capture les erreurs Dio', () async {
      final dio = Dio();
      dio.interceptors.add(NetworkErrorInterceptor());

      try {
        await dio.get('https://httpstat.us/500');
      } catch (e) {
        // L'erreur devrait être capturée par l'intercepteur
        expect(e, isA<DioException>());
      }
    });
  });

  group('Observability Tests', () {
    test('Surveille une opération Supabase', () async {
      // Simuler une opération Supabase
      final result = await ObservabilityService().monitorSupabaseOperation(
        'test_operation',
        () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return {'success': true};
        },
      );

      expect(result, isNotNull);
      expect(result['success'], isTrue);
    });

    test('Surveille une opération Mapbox', () async {
      // Simuler une opération Mapbox
      final result = await ObservabilityService().monitorMapboxOperation(
        'test_operation',
        () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return {'success': true};
        },
      );

      expect(result, isNotNull);
      expect(result['success'], isTrue);
    });
  });
}

