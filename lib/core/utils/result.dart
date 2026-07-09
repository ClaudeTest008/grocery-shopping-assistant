import '../errors/failures.dart';

/// Lightweight Result type for repository return values.
/// UI usually consumes these through Riverpod [AsyncValue]; Result keeps
/// failures typed between data and domain layers.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) => switch (this) {
    Ok(:final value) => ok(value),
    Err(:final failure) => err(failure),
  };

  T getOrThrow() => switch (this) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };

  T getOrElse(T fallback) => switch (this) {
    Ok(:final value) => value,
    Err() => fallback,
  };

  bool get isOk => this is Ok<T>;

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs [body], mapping common raw exceptions to [Failure]s.
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on Failure catch (f) {
    return Err(f);
  } catch (e) {
    return Err(UnknownFailure(e.toString(), e));
  }
}
