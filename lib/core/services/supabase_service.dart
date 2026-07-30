import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../errors/failures.dart';

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

extension SupabaseSession on SupabaseClient {
  /// The signed-in user's id, or an [AuthFailure] the UI already knows
  /// how to render.
  ///
  /// Repositories used to reach for `currentUser!.id`, so an expired or
  /// revoked session surfaced as "Null check operator used on a null
  /// value" on a screen with no way out. Sessions do expire in normal
  /// use, so this is a routine path, not an edge case.
  String get requireUserId {
    final id = auth.currentUser?.id;
    if (id == null) {
      throw const AuthFailure('Your session has expired — sign in again');
    }
    return id;
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
