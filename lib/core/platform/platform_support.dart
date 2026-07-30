import 'package:flutter/foundation.dart';

/// Single source of truth for platform capability checks.
///
/// Several plugins ship native implementations for only some platforms.
/// Rather than scattering `Platform.isX` checks through the UI (and
/// crashing with `MissingPluginException` where a plugin is absent),
/// features ask this class what the current platform can do and degrade
/// gracefully when the answer is no.
///
/// Deliberately uses [defaultTargetPlatform] rather than `dart:io`'s
/// `Platform`: importing `dart:io` breaks the web build.
abstract final class PlatformSupport {
  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get _isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// True on Windows, Linux and macOS builds.
  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          _isMacOS);

  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Camera-based barcode scanning (`mobile_scanner`).
  /// No Windows/Linux implementation — desktop users type the barcode.
  static bool get hasBarcodeScanner =>
      kIsWeb || _isAndroid || _isIOS || _isMacOS;

  /// On-device OCR (`google_mlkit_text_recognition`): mobile only.
  /// Desktop and web fall back to manual receipt entry.
  static bool get hasOcr => _isAndroid || _isIOS;

  /// Live camera capture through `image_picker`. On desktop `image_picker`
  /// is backed by `file_selector_windows`, which can open files but not
  /// drive a camera.
  static bool get hasCamera => _isAndroid || _isIOS;

  /// Picking an existing image file. Works everywhere the app runs,
  /// including Windows (via the native file picker).
  static bool get hasImageLibrary => true;

  /// Native Stripe payment sheet (`flutter_stripe`): no desktop support.
  static bool get hasPaymentSheet => kIsWeb || _isAndroid || _isIOS;

  /// Push notifications (`firebase_messaging`): no Windows support.
  static bool get hasPushMessaging =>
      kIsWeb || _isAndroid || _isIOS || _isMacOS;

  /// Speech-to-text is available on Windows via `speech_to_text_windows`.
  static bool get hasSpeechToText =>
      kIsWeb || _isAndroid || _isIOS || _isMacOS || isWindows;

  /// Human-readable reason shown when a capability is missing, e.g.
  /// "Barcode scanning isn't available on Windows".
  static String get platformName {
    if (kIsWeb) return 'the web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }
}
