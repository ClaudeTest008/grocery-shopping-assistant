import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failures.dart';

/// Shared Dio instance for non-Supabase HTTP (LLM providers, external
/// price APIs). Supabase traffic goes through supabase_flutter.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(_ErrorMappingInterceptor());
  return dio;
});

class _ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        NetworkFailure('Connection failed', err),
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
