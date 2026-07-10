import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Central observability: uncaught-error capture + product analytics.
///
/// Demo mode / debug: everything goes to the console. With Supabase
/// configured, events land in the `analytics` table (RLS: insert-own).
/// Crash reporting is a single integration point: plug Sentry/Crashlytics
/// into [recordError] (AppConfig.sentryDsn is already plumbed through
/// dart-define) without touching call sites.
abstract final class Telemetry {
  static bool _installed = false;

  /// Installs global handlers for framework and platform errors.
  static void installErrorHandlers() {
    if (_installed) return;
    _installed = true;

    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      recordError(details.exception, details.stack, fatal: false);
      previous?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, fatal: true);
      return true; // handled — keep the app alive where possible
    };
  }

  static void recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) {
    // Integration point: Sentry.captureException / Crashlytics.recordError.
    debugPrint('[telemetry] ${fatal ? 'FATAL' : 'error'}: $error');
    if (kDebugMode && stack != null) debugPrintStack(stackTrace: stack);
    _tryInsert('app_error', {
      'error': error.toString().substring(
        0,
        error.toString().length.clamp(0, 500),
      ),
      'fatal': fatal,
    });
  }

  /// Product analytics event (screen views, feature usage).
  static void logEvent(String event, [Map<String, dynamic>? properties]) {
    debugPrint('[telemetry] $event ${properties ?? ''}');
    _tryInsert(event, properties);
  }

  static void _tryInsert(String event, Map<String, dynamic>? properties) {
    if (AppConfig.isDemoMode) return;
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;
      // Fire and forget; analytics must never break the app.
      client
          .from('analytics')
          .insert({'user_id': userId, 'event': event, 'properties': properties})
          .then((_) {}, onError: (_) {});
    } catch (_) {
      // Supabase not initialized — console-only.
    }
  }
}

/// Riverpod observer logging provider failures to telemetry.
final class TelemetryProviderObserver extends ProviderObserver {
  const TelemetryProviderObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Telemetry.recordError(error, stackTrace);
  }
}
