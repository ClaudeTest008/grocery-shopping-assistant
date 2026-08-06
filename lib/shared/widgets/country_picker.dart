import 'package:flutter/material.dart';

import '../../app_bootstrap.dart';
import '../../core/config/app_config.dart';
import '../../core/demo/demo_seed.dart';
import '../../core/geo/countries.dart';
import '../../core/geo/selected_country.dart';
import '../../core/observability/telemetry.dart';
import '../../core/storage/local_store.dart';

/// One country switcher for every entry point (settings, map,
/// onboarding). Switching reloads the whole app scope: stores, prices,
/// products, coupons, offers, currency — everything derives from the
/// selected [CountryConfig], so nothing needs to be updated piecemeal.
Future<void> showCountryPicker(BuildContext context) async {
  final current = DemoSeed.country;
  final chosen = await showDialog<CountryConfig>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Choose your country'),
      children: [
        for (final country in Countries.all)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, country),
            child: Row(
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.name,
                        style: TextStyle(
                          fontWeight: country.code == current.code
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${country.city} · ${country.currency}',
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (country.code == current.code)
                  const Icon(Icons.check_rounded, size: 18),
              ],
            ),
          ),
      ],
    ),
  );
  if (chosen == null || chosen.code == current.code) return;
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Switch to ${chosen.flag} ${chosen.name}?'),
      content: Text(
        AppConfig.isDemoMode
            ? 'The demo reloads for ${chosen.city}: ${chosen.name} stores, '
                  '${chosen.currency} prices and local product names. '
                  'Demo lists, pantry and receipts on this device reset.'
            : 'Stores, prices and product names reload for ${chosen.city}. '
                  'Your account data is unaffected; local caches reset.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Switch'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  Telemetry.logEvent('country_switched', {
    'from': current.code,
    'to': chosen.code,
  });
  // Order matters: the wipe clears the prefs box, so persist AFTER it.
  await LocalStore.instance.wipe();
  await SelectedCountry.apply(chosen);
  // Full scope rebuild: every provider re-reads the new country's data.
  AppBootstrap.restartGlobal();
}
