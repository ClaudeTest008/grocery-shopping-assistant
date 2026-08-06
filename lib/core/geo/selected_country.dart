import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../demo/demo_seed.dart';
import '../storage/local_store.dart';
import '../utils/formatters.dart';
import 'countries.dart';

/// The one place the active country is chosen and applied.
///
/// Resolution order: explicit user choice (persisted) → device locale →
/// registry fallback. Applying a country updates every derived global
/// (demo seed, currency formatting); callers restart the app scope so
/// providers re-read.
abstract final class SelectedCountry {
  static const _prefKey = 'country_code';

  static CountryConfig resolveInitial() {
    final saved = LocalStore.instance.prefs.get(_prefKey);
    if (saved is String && Countries.supports(saved)) {
      return Countries.byCode(saved);
    }
    // Automatic detection: the device's region, when we support it.
    final device = PlatformDispatcher.instance.locale.countryCode;
    if (device != null && Countries.supports(device)) {
      return Countries.byCode(device);
    }
    return Countries.fallback;
  }

  /// Makes [config] the active country. [persist] false during boot
  /// (nothing chosen — resolution just ran).
  static Future<void> apply(CountryConfig config, {bool persist = true}) async {
    DemoSeed.country = config;
    Formatters.defaultCurrency = config.currency;
    // Dates and numbers follow the country everywhere Formatters is
    // used: 05/03/2026 and 1.234,56 € in Madrid, Mar 5 and $1,234.56
    // in Austin — one assignment, zero per-screen work.
    final locale = '${config.primaryLanguage}_${config.code}';
    try {
      await initializeDateFormatting(config.primaryLanguage);
      Intl.defaultLocale = locale;
    } catch (_) {
      // Unknown locale data: keep the previous locale rather than crash
      // at boot. English formatting is a degraded state, not a failure.
    }
    if (persist) {
      await LocalStore.instance.prefs.put(_prefKey, config.code);
    }
  }
}

/// Rebuilt with the app scope on restart, so a country switch flows to
/// every watcher.
final selectedCountryProvider = Provider<CountryConfig>(
  (_) => DemoSeed.country,
);
