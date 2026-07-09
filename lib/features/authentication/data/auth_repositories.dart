import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final sb.SupabaseClient _client;

  AppUser? _map(sb.User? u) => u == null
      ? null
      : AppUser(
          id: u.id,
          email: u.email ?? '',
          displayName: u.userMetadata?['full_name'] as String?,
          avatarUrl: u.userMetadata?['avatar_url'] as String?,
        );

  @override
  Stream<AppUser?> authStateChanges() =>
      _client.auth.onAuthStateChange.map((s) => _map(s.session?.user));

  @override
  AppUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on sb.AuthException catch (e) {
      throw AuthFailure(e.message, e);
    }
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
    } on sb.AuthException catch (e) {
      throw AuthFailure(e.message, e);
    }
  }

  @override
  Future<void> signInWithGoogle() => _oauth(sb.OAuthProvider.google);

  @override
  Future<void> signInWithApple() => _oauth(sb.OAuthProvider.apple);

  Future<void> _oauth(sb.OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'com.groceryassistant.grocery://login-callback',
      );
    } on sb.AuthException catch (e) {
      throw AuthFailure(e.message, e);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

/// Demo mode: a single local user, always signed in after any auth
/// action, so the whole app is explorable without a backend.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository() {
    _controller.add(_user);
  }

  static const _user = AppUser(
    id: DemoSeed.demoUserId,
    email: 'demo@grocery.app',
    displayName: 'Demo Shopper',
  );

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current = _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _current;

  @override
  Future<void> signInWithEmail(String email, String password) async =>
      _set(_user);

  @override
  Future<void> signUpWithEmail(String email, String password) async =>
      _set(_user);

  @override
  Future<void> signInWithGoogle() async => _set(_user);

  @override
  Future<void> signInWithApple() async => _set(_user);

  @override
  Future<void> signOut() async => _set(null);

  void _set(AppUser? u) {
    _current = u;
    _controller.add(u);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.isDemoMode) return DemoAuthRepository();
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authStateProvider).valueOrNull,
);
