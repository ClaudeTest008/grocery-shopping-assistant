import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failures.dart';
import '../observability/telemetry.dart';

/// Shared Dio instance for non-Supabase HTTP (LLM providers, external
/// price APIs). Supabase traffic goes through supabase_flutter.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(_LatencyInterceptor());
  dio.interceptors.add(_ErrorMappingInterceptor());
  return dio;
});

/// Latency per external request: host + path template only — never
/// query strings, bodies, or headers, which can carry user content.
class _LatencyInterceptor extends Interceptor {
  static const _startedAt = '_telemetry_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAt] = DateTime.now();
    handler.next(options);
  }

  void _log(RequestOptions options, int? status) {
    final started = options.extra[_startedAt];
    if (started is! DateTime) return;
    Telemetry.logEvent('http_request', {
      'host': options.uri.host,
      'path': options.uri.path,
      'status': status,
      'ms': DateTime.now().difference(started).inMilliseconds,
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(err.requestOptions, err.response?.statusCode);
    handler.next(err);
  }
}

class _ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError => NetworkFailure(
        'Connection failed',
        err,
      ),
      DioExceptionType.badResponse => switch (err.response?.statusCode) {
        401 || 403 => AuthFailure('Not authorized', err),
        404 => NotFoundFailure('Resource not found', err),
        429 => const ServerFailure('Rate limited — try again shortly'),
        _ => ServerFailure('Server error ${err.response?.statusCode}', err),
      },
      _ => UnknownFailure(err.message ?? 'Request failed', err),
    };
    handler.reject(err.copyWith(error: failure));
  }
}
