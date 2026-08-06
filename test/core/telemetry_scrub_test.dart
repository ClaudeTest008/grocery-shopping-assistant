import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/observability/telemetry.dart';

/// scrub() is what stands between an error string and the analytics
/// table — these pin the shapes user data actually takes in errors.
void main() {
  test('strips email addresses', () {
    expect(
      Telemetry.scrub('duplicate key users_email_key: jane.doe+x@mail.com'),
      isNot(contains('jane.doe')),
    );
    expect(Telemetry.scrub('x jane@mail.com y'), contains('<email>'));
  });

  test('strips URL query strings', () {
    final out = Telemetry.scrub(
      'GET https://api.example.com/search?q=insulin+syringes&token=abc failed',
    );
    expect(out, isNot(contains('insulin')));
    expect(out, isNot(contains('token=abc')));
    expect(out, contains('https://api.example.com/search'));
  });

  test('strips long digit runs (barcodes, phone numbers)', () {
    final out = Telemetry.scrub('no product for barcode 737628064502');
    expect(out, isNot(contains('737628064502')));
    expect(out, contains('<digits>'));
  });

  test('keeps short codes needed for triage', () {
    expect(Telemetry.scrub('HTTP 429 after 3 tries'), contains('429'));
  });

  test('truncates to 300 chars after scrubbing', () {
    expect(Telemetry.scrub('x' * 500).length, lessThanOrEqualTo(301));
  });

  test('redact only truncates — the user-reviewed feedback path', () {
    expect(Telemetry.redact('mail me at a@b.co'), contains('a@b.co'));
  });
}
