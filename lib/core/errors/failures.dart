/// Domain-level failure hierarchy. Repositories catch raw exceptions
/// (Dio, Supabase, Hive, platform) and surface one of these instead so
/// the presentation layer never depends on data-source packages.
sealed class Failure implements Exception {
  const Failure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network unavailable', super.cause]);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error', super.cause]);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed', super.cause]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found', super.cause]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.cause]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error', super.cause]);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied', super.cause]);
}

final class AiFailure extends Failure {
  const AiFailure([super.message = 'AI service error', super.cause]);
}

final class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Payment failed', super.cause]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong', super.cause]);
}
