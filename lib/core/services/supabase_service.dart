import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Initializes Supabase when configured. Safe no-op in demo mode.
abstract final class SupabaseService {
  static Future<void> init() async {
    if (!AppConfig.hasSupabase) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }
}

/// Throws if accessed in demo mode — repositories must check
/// [AppConfig.isDemoMode] before depending on this.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (AppConfig.isDemoMode) {
    throw StateError(
      'Supabase not configured. Repositories must use mock data sources '
      'in demo mode.',
    );
  }
  return Supabase.instance.client;
});
