import 'app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<void> signInWithEmail(String email, String password);

  Future<void> signUpWithEmail(String email, String password);

  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> signOut();

  /// Permanently deletes the account and every piece of server-side
  /// data. Irreversible; callers own the confirmation UX.
  Future<void> deleteAccount();
}
