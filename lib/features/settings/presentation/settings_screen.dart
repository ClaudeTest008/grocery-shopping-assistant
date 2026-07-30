import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_bootstrap.dart';
import '../../../core/config/app_config.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/section_header.dart';
import '../../profile/data/preferences_repository.dart';
import '../../profile/domain/user_preferences.dart';
import 'account_section.dart';

Future<void> _resetDemo(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Reset demo data?'),
      content: const Text(
        'This clears your lists, pantry, receipts, meal plans and '
        'settings, restoring the original demo dataset. It cannot be '
        'undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Reset'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(localStoreProvider).wipe();
  if (context.mounted) AppBootstrap.restart(context);
}

const _currencies = ['USD', 'EUR', 'GBP', 'CAD'];
const _dietaryOptions = [
  'vegan',
  'vegetarian',
  'gluten_free',
  'dairy_free',
  'nut_free',
  'halal',
  'kosher',
];

String _titleCase(String snake) => snake
    .split('_')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SectionHeader(title: 'Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'system',
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_rounded),
                ),
                ButtonSegment(
                  value: 'light',
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_rounded),
                ),
                ButtonSegment(
                  value: 'dark',
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_rounded),
                ),
              ],
              selected: {prefs.themeMode},
              onSelectionChanged: (s) =>
                  notifier.update(prefs.copyWith(themeMode: s.first)),
            ),
          ),
          SwitchListTile(
            title: const Text('High contrast'),
            subtitle: const Text('Increase contrast for better readability'),
            value: prefs.highContrast,
            onChanged: (v) => notifier.update(prefs.copyWith(highContrast: v)),
          ),
          ListTile(
            title: const Text('Text size'),
            subtitle: Text('${(prefs.textScale * 100).round()}%'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: prefs.textScale.clamp(0.8, 1.4).toDouble(),
              min: 0.8,
              max: 1.4,
              divisions: 12,
              label: '${(prefs.textScale * 100).round()}%',
              onChanged: (v) => notifier.update(prefs.copyWith(textScale: v)),
            ),
          ),
          const SectionHeader(title: 'Localization'),
          ListTile(
            title: const Text('Currency'),
            trailing: DropdownButton<String>(
              value: prefs.currency,
              underline: const SizedBox.shrink(),
              items: [
                for (final c in _currencies)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) {
                if (v != null) notifier.update(prefs.copyWith(currency: v));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'imperial', label: Text('Imperial')),
                ButtonSegment(value: 'metric', label: Text('Metric')),
              ],
              selected: {prefs.units},
              onSelectionChanged: (s) =>
                  notifier.update(prefs.copyWith(units: s.first)),
            ),
          ),
          const SectionHeader(title: 'Budget'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _BudgetField(prefs: prefs, notifier: notifier),
          ),
          const SectionHeader(title: 'Dietary restrictions'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _dietaryOptions)
                  FilterChip(
                    label: Text(_titleCase(option)),
                    selected: prefs.dietaryRestrictions.contains(option),
                    onSelected: (selected) {
                      final restrictions = [...prefs.dietaryRestrictions];
                      if (selected) {
                        restrictions.add(option);
                      } else {
                        restrictions.remove(option);
                      }
                      notifier.update(
                        prefs.copyWith(dietaryRestrictions: restrictions),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Notifications'),
            value: prefs.notificationsEnabled,
            onChanged: (v) =>
                notifier.update(prefs.copyWith(notificationsEnabled: v)),
          ),
          SwitchListTile(
            title: const Text('Price drop alerts'),
            value: prefs.priceDropAlerts,
            onChanged: prefs.notificationsEnabled
                ? (v) => notifier.update(prefs.copyWith(priceDropAlerts: v))
                : null,
          ),
          SwitchListTile(
            title: const Text('Coupon expiry alerts'),
            value: prefs.couponExpiryAlerts,
            onChanged: prefs.notificationsEnabled
                ? (v) => notifier.update(prefs.copyWith(couponExpiryAlerts: v))
                : null,
          ),
          const SectionHeader(title: 'Shopping trips'),
          ListTile(
            title: const Text('Fuel cost per km'),
            subtitle: Text(
              '${Formatters.currency(prefs.fuelCostPerKm, code: prefs.currency)} — '
              'used to weigh the cost of driving to another store',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: prefs.fuelCostPerKm.clamp(0.05, 0.30).toDouble(),
              min: 0.05,
              max: 0.30,
              divisions: 25,
              label: Formatters.currency(
                prefs.fuelCostPerKm,
                code: prefs.currency,
              ),
              onChanged: (v) =>
                  notifier.update(prefs.copyWith(fuelCostPerKm: v)),
            ),
          ),
          ListTile(
            title: const Text('Multi-store savings threshold'),
            subtitle: Text(
              'Only suggest splitting a trip across stores when it saves '
              'at least ${Formatters.currency(prefs.multiStoreThreshold, code: prefs.currency)}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: prefs.multiStoreThreshold.clamp(0, 10).toDouble(),
              min: 0,
              max: 10,
              divisions: 20,
              label: Formatters.currency(
                prefs.multiStoreThreshold,
                code: prefs.currency,
              ),
              onChanged: (v) =>
                  notifier.update(prefs.copyWith(multiStoreThreshold: v)),
            ),
          ),
          ListTile(
            title: const Text('Value of your time'),
            subtitle: Text(
              prefs.valueOfTimePerHour == 0
                  ? 'Off — optimize on money alone'
                  : '${Formatters.currency(prefs.valueOfTimePerHour, code: prefs.currency)}/hour '
                        'of driving is added to trip totals',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: prefs.valueOfTimePerHour.clamp(0, 60).toDouble(),
              min: 0,
              max: 60,
              divisions: 12,
              label: prefs.valueOfTimePerHour == 0
                  ? 'Off'
                  : '${Formatters.currency(prefs.valueOfTimePerHour, code: prefs.currency)}/h',
              onChanged: (v) =>
                  notifier.update(prefs.copyWith(valueOfTimePerHour: v)),
            ),
          ),
          const AccountAndDataSection(),
          const SectionHeader(title: 'About'),
          ListTile(
            title: const Text('Version'),
            trailing: Text(ref.watch(appVersionProvider).value ?? '…'),
          ),
          if (AppConfig.isDemoMode) ...[
            ListTile(
              leading: Icon(
                Icons.info_outline_rounded,
                color: context.colors.primary,
              ),
              title: const Text('Demo mode'),
              subtitle: const Text(
                'No backend configured — running on seeded local data',
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.restart_alt_rounded,
                color: context.colors.error,
              ),
              title: const Text('Reset demo data'),
              subtitle: const Text(
                'Restore the original seeded lists, pantry, receipts and '
                'settings',
              ),
              onTap: () => _resetDemo(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}

/// Standalone controller so the field keeps its cursor/focus across
/// rebuilds triggered by other settings changing.
class _BudgetField extends ConsumerStatefulWidget {
  const _BudgetField({required this.prefs, required this.notifier});

  final UserPreferences prefs;
  final PreferencesNotifier notifier;

  @override
  ConsumerState<_BudgetField> createState() => _BudgetFieldState();
}

class _BudgetFieldState extends ConsumerState<_BudgetField> {
  late final _controller = TextEditingController(
    text: widget.prefs.monthlyBudget?.toStringAsFixed(2) ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final parsed = double.tryParse(value.trim());
    widget.notifier.update(widget.prefs.copyWith(monthlyBudget: parsed));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Monthly budget',
        prefixText: '${widget.prefs.currency} ',
      ),
      onSubmitted: _submit,
      onTapOutside: (_) => _submit(_controller.text),
    );
  }
}
