import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/errors/failures.dart';
import 'package:grocery_shopping_assistant/core/utils/result.dart';

void main() {
  group('Result', () {
    test('Ok carries value through map/when/getOrThrow', () {
      const Result<int> result = Ok(2);
      expect(result.isOk, isTrue);
      expect(result.map((v) => v * 2).getOrThrow(), 4);
      expect(result.when(ok: (v) => v, err: (_) => -1), 2);
    });

    test('Err propagates failure', () {
      const Result<int> result = Err(NetworkFailure());
      expect(result.isOk, isFalse);
      expect(result.getOrElse(7), 7);
      expect(() => result.getOrThrow(), throwsA(isA<NetworkFailure>()));
      expect(result.map((v) => v * 2), isA<Err<int>>());
    });

    test('guard wraps thrown Failure as Err', () async {
      final result = await guard<int>(
        () async => throw const AuthFailure('nope'),
      );
      expect(result, isA<Err<int>>());
      result.when(
        ok: (_) => fail('should be Err'),
        err: (f) => expect(f, isA<AuthFailure>()),
      );
    });

    test('guard wraps unknown exceptions as UnknownFailure', () async {
      final result = await guard<int>(() async => throw StateError('x'));
      result.when(
        ok: (_) => fail('should be Err'),
        err: (f) => expect(f, isA<UnknownFailure>()),
      );
    });
  });
}
