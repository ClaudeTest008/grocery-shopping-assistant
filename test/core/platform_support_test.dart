import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/platform/platform_support.dart';

/// Guards the capability matrix that keeps Windows/desktop builds from
/// calling into plugins that have no implementation there.
void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('Windows', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.windows);

    test('is desktop', () {
      expect(PlatformSupport.isWindows, isTrue);
      expect(PlatformSupport.isDesktop, isTrue);
      expect(PlatformSupport.platformName, 'Windows');
    });

    test('reports plugins without a Windows implementation as unavailable', () {
      expect(PlatformSupport.hasBarcodeScanner, isFalse); // mobile_scanner
      expect(PlatformSupport.hasOcr, isFalse); // google_mlkit
      expect(PlatformSupport.hasCamera, isFalse);
      expect(PlatformSupport.hasPaymentSheet, isFalse); // flutter_stripe
      expect(PlatformSupport.hasPushMessaging, isFalse); // firebase_messaging
    });

    test('keeps capabilities that do ship a Windows plugin', () {
      // speech_to_text_windows and file_selector_windows are registered
      // in windows/flutter/generated_plugin_registrant.cc.
      expect(PlatformSupport.hasSpeechToText, isTrue);
      expect(PlatformSupport.hasImageLibrary, isTrue);
    });
  });

  group('Android', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

    test('keeps every mobile capability', () {
      expect(PlatformSupport.isDesktop, isFalse);
      expect(PlatformSupport.hasBarcodeScanner, isTrue);
      expect(PlatformSupport.hasOcr, isTrue);
      expect(PlatformSupport.hasCamera, isTrue);
      expect(PlatformSupport.hasPaymentSheet, isTrue);
      expect(PlatformSupport.hasPushMessaging, isTrue);
      expect(PlatformSupport.platformName, 'Android');
    });
  });

  group('iOS', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);

    test('keeps every mobile capability', () {
      expect(PlatformSupport.hasBarcodeScanner, isTrue);
      expect(PlatformSupport.hasOcr, isTrue);
      expect(PlatformSupport.hasPaymentSheet, isTrue);
      expect(PlatformSupport.platformName, 'iOS');
    });
  });

  group('macOS', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.macOS);

    test('has scanning but no on-device OCR', () {
      expect(PlatformSupport.isDesktop, isTrue);
      expect(PlatformSupport.hasBarcodeScanner, isTrue);
      expect(PlatformSupport.hasOcr, isFalse);
    });
  });
}
