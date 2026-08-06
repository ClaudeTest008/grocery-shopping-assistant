import 'package:flutter/material.dart';

import 'app_bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/observability/telemetry.dart';
import 'core/platform/platform_support.dart';
import 'core/services/notification_service.dart';
import 'core/services/stripe_service.dart';
import 'core/services/supabase_service.dart';
import 'core/storage/local_store.dart';

/// Kept top-level so the listener is never garbage-collected: it is
/// referenced only by assignment but must outlive main() to keep
/// receiving lifecycle callbacks.
// ignore: unused_element
AppLifecycleListener? _lifecycle;

Future<void> main() async {
  final startup = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();
  Telemetry.installErrorHandlers();

  await LocalStore.init();
  await SupabaseService.init();
  // Push + payments degrade gracefully when unconfigured.
  await NotificationService.init();
  await StripeService.init();
  final initMs = startup.elapsedMilliseconds;

  // Startup is measured, not guessed: init cost and time-to-first-frame
  // land in the log on every launch, so a regression is visible the day
  // it happens rather than when users complain. mode/platform make this
  // the DAU/WAU + demo-vs-connected event with zero extra collection.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    startup.stop();
    Telemetry.logEvent('startup', {
      'init_ms': initMs,
      'first_frame_ms': startup.elapsedMilliseconds,
      'mode': AppConfig.isDemoMode ? 'demo' : 'connected',
      'platform': PlatformSupport.platformName,
    });
  });

  // Session duration: one foreground stretch per event. Best effort —
  // a force-kill loses the final event, which biases durations short,
  // never long.
  final session = Stopwatch()..start();
  _lifecycle = AppLifecycleListener(
    onStateChange: (state) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.hidden) {
        if (session.isRunning) {
          session.stop();
          Telemetry.logEvent('session_end', {
            'seconds': session.elapsed.inSeconds,
          });
        }
      } else if (state == AppLifecycleState.resumed) {
        // Reset only after a logged stretch: inactive→resumed cycles
        // (permission dialogs, app-switcher peeks) never reach
        // paused/hidden and must not zero a running session.
        if (!session.isRunning) {
          session
            ..reset()
            ..start();
        }
      }
    },
  );

  runApp(const AppBootstrap());
}
