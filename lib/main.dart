import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/stripe_service.dart';
import 'core/services/supabase_service.dart';
import 'core/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStore.init();
  await SupabaseService.init();
  // Push + payments degrade gracefully when unconfigured.
  await NotificationService.init();
  await StripeService.init();

  runApp(const ProviderScope(child: GroceryApp()));
}
