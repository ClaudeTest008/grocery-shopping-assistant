import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/local_store.dart';
import '../domain/user_preferences.dart';

/// Preferences live locally (Hive) for instant reads and offline writes,
/// and sync to Supabase when a backend is configured — local copy is the
/// source of truth on conflict (last write wins).
class PreferencesRepository {
  PreferencesRepository(this._store, this._client);

  final LocalStore _store;
  final SupabaseClient? _client;

  static const _key = 'user_preferences';

  UserPreferences load() {
    final raw = _store.prefs.get(_key);
    if (raw is Map) {
      return UserPreferences.fromJson(Map<String, dynamic>.from(raw));
    }
    return const UserPreferences();
  }

  Future<void> save(UserPreferences prefs) async {
    await _store.prefs.put(_key, prefs.toJson());
    final client = _client;
    final userId = client?.auth.currentUser?.id;
    if (client != null && userId != null) {
      try {
        await client.from('preferences').upsert({
          'user_id': userId,
          'data': prefs.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Offline or transient — local copy already saved; sync retries
        // next save.
      }
    }
  }
}

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository(
    ref.watch(localStoreProvider),
    AppConfig.isDemoMode ? null : Supabase.instance.client,
  );
});

/// App-wide reactive preferences.
class PreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() => ref.watch(preferencesRepositoryProvider).load();

  Future<void> update(UserPreferences prefs) async {
    state = prefs;
    await ref.read(preferencesRepositoryProvider).save(prefs);
  }
}

final preferencesProvider =
    NotifierProvider<PreferencesNotifier, UserPreferences>(
        PreferencesNotifier.new);
