import 'package:flutter/material.dart';

import 'app_bootstrap.dart';
import 'core/observability/telemetry.dart';
import 'core/services/notification_service.dart';
import 'core/services/stripe_service.dart';
import 'core/services/supabase_service.dart';
import 'core/storage/local_store.dart';

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
  // it happens rather than when users complain.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    startup.stop();
    Telemetry.logEvent('startup', {
      'init_ms': initMs,
      'first_frame_ms': startup.elapsedMilliseconds,
    });
  });

  runApp(const AppBootstrap());
}
