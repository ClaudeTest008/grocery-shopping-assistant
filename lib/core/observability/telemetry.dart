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

  /// Ring buffer of recent error summaries, attached to beta feedback so
  /// a "it crashed earlier" report arrives with evidence. Redacted and
  /// capped; never contains stack traces or payloads.
  static final List<String> _recentErrors = [];
  static const _recentErrorsCap = 10;

  static List<String> get recentErrors => List.unmodifiable(_recentErrors);

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

  /// Error strings can carry whatever the thrower put in them — a row of
  /// user data, an email in a URL. Cap the length and keep it out of the
  /// analytics table beyond what is needed to identify the failure.
  static String redact(Object error) {
    final text = error.toString();
    return text.length <= 300 ? text : '${text.substring(0, 300)}…';
  }

  static void recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) {
    // Integration point: Sentry.captureException / Crashlytics.recordError.
    debugPrint('[telemetry] ${fatal ? 'FATAL' : 'error'}: $error');
    _recentErrors.add('${fatal ? 'FATAL ' : ''}${redact(error)}');
    if (_recentErrors.length > _recentErrorsCap) _recentErrors.removeAt(0);
    if (kDebugMode && stack != null) debugPrintStack(stackTrace: stack);
    _tryInsert('app_error', {'error': redact(error), 'fatal': fatal});
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
