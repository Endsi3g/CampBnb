/// Intercepteurs pour capturer les erreurs réseau (Dio, HTTP)
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'error_monitoring_service.dart';

/// Intercepteur Dio pour capturer les erreurs réseau
class NetworkErrorInterceptor extends Interceptor {
  final ErrorMonitoringService _errorService = ErrorMonitoringService();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _errorService.captureNetworkError(
      url: err.requestOptions.uri.toString(),
      statusCode: err.response?.statusCode ?? 0,
      method: err.requestOptions.method,
      requestData: err.requestOptions.data,
      responseBody: err.response?.data?.toString(),
      exception: err,
      stackTrace: err.stackTrace,
    );

    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ajouter un breadcrumb pour tracer les requêtes
    _errorService.addBreadcrumb(
      message: '${options.method} ${options.uri}',
      category: 'network',
      data: {'method': options.method, 'url': options.uri.toString()},
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Tracer les réponses lentes
    final duration = response.extra['duration'] as Duration?;
    if (duration != null && duration.inMilliseconds > 2000) {
      _errorService.capturePerformanceIssue(
        operation:
            '${response.requestOptions.method} ${response.requestOptions.uri}',
        duration: duration,
        context: 'Network request took longer than expected',
      );
    }

    super.onResponse(response, handler);
  }
}

/// Wrapper HTTP pour capturer les erreurs
class MonitoredHttpClient {
  final http.Client _client;
  final ErrorMonitoringService _errorService = ErrorMonitoringService();

  MonitoredHttpClient(this._client);

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final stopwatch = Stopwatch()..start();
    try {
      _errorService.addBreadcrumb(message: 'GET $url', category: 'network');

      final response = await _client.get(url, headers: headers);
      stopwatch.stop();

      if (stopwatch.elapsedMilliseconds > 2000) {
        _errorService.capturePerformanceIssue(
          operation: 'GET $url',
          duration: stopwatch.elapsed,
        );
      }

      if (response.statusCode >= 400) {
        await _errorService.captureNetworkError(
          url: url.toString(),
          statusCode: response.statusCode,
          method: 'GET',
          responseBody: response.body.substring(0, 500),
        );
      }

      return response;
    } catch (e, stackTrace) {
      await _errorService.captureNetworkError(
        url: url.toString(),
        statusCode: 0,
        method: 'GET',
        exception: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      _errorService.addBreadcrumb(message: 'POST $url', category: 'network');

      final response = await _client.post(url, headers: headers, body: body);
      stopwatch.stop();

      if (stopwatch.elapsedMilliseconds > 2000) {
        _errorService.capturePerformanceIssue(
          operation: 'POST $url',
          duration: stopwatch.elapsed,
        );
      }

      if (response.statusCode >= 400) {
        await _errorService.captureNetworkError(
          url: url.toString(),
          statusCode: response.statusCode,
          method: 'POST',
          requestData: body is Map ? body : null,
          responseBody: response.body.substring(0, 500),
        );
      }

      return response;
    } catch (e, stackTrace) {
      await _errorService.captureNetworkError(
        url: url.toString(),
        statusCode: 0,
        method: 'POST',
        requestData: body is Map ? body : null,
        exception: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void close() => _client.close();
}
