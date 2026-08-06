import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_bootstrap.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../../../core/observability/telemetry.dart';
import '../../../core/platform/platform_support.dart';
import '../../../core/storage/local_store.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/section_header.dart';
import '../../authentication/data/auth_repositories.dart';
import '../../meal_planner/data/meal_plan_repositories.dart';
import '../../pantry/data/pantry_repositories.dart';
import '../../profile/data/preferences_repository.dart';
import '../../receipts/data/receipt_repositories.dart';
import '../../shopping_lists/data/shopping_list_repositories.dart';

const supportEmail = 'support@grocery-assistant.app';
const privacyUrl =
    'https://github.com/ClaudeTest008/grocery-shopping-assistant/blob/main/PRIVACY.md';
const termsUrl =
    'https://github.com/ClaudeTest008/grocery-shopping-assistant/blob/main/TERMS.md';

/// The app's real version, read from the platform rather than hardcoded
/// so the About screen can never drift from the build again.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// "Account & data" — the store-compliance surface: export everything,
/// delete everything, and the legal texts. Kept in its own widget so
/// SettingsScreen stays readable.
class AccountAndDataSection extends ConsumerWidget {
  const AccountAndDataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Account & data'),
        ListTile(
          leading: const Icon(Icons.download_rounded),
          title: const Text('Export my data'),
          subtitle: const Text(
            'Copy your lists, pantry, receipts and settings as JSON',
          ),
          onTap: () => _exportData(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.mail_outline_rounded),
          title: const Text('Send feedback'),
          subtitle: const Text('Email us — build info is attached'),
          onTap: () => _sendFeedback(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.policy_outlined),
          title: const Text('Privacy policy'),
          onTap: () => _openUrl(context, privacyUrl),
        ),
        ListTile(
          leading: const Icon(Icons.gavel_rounded),
          title: const Text('Terms of use'),
          onTap: () => _openUrl(context, termsUrl),
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever_rounded,
            color: context.colors.error,
          ),
          title: Text(
            'Delete account',
            style: TextStyle(color: context.colors.error),
          ),
          subtitle: Text(
            AppConfig.isDemoMode
                ? 'Erases all local demo data on this device'
                : 'Permanently removes your account and every trace of '
                      'your data',
          ),
          onTap: () => _deleteAccount(context, ref),
        ),
      ],
    );
  }

  /// Everything the app knows about the user, as one JSON document on
  /// the clipboard. Deliberately clipboard rather than a file: it works
  /// identically on all four platforms with zero new permissions.
  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    // Read every provider before the first await: WidgetRef throws if
    // used after this widget unmounts, and the user can navigate away
    // while the repositories load.
    final listRepo = ref.read(shoppingListRepositoryProvider);
    final pantryRepo = ref.read(pantryRepositoryProvider);
    final receiptRepo = ref.read(receiptRepositoryProvider);
    final mealPlanRepo = ref.read(mealPlanRepositoryProvider);
    final preferences = ref.read(preferencesProvider);
    try {
      final lists = await listRepo.lists();
      final pantry = await pantryRepo.items();
      final receipts = await receiptRepo.receipts();
      final monday = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1),
      );
      final plan = await mealPlanRepo.forWeek(
        DateTime(monday.year, monday.month, monday.day),
      );

      final export = const JsonEncoder.withIndent('  ').convert({
        'exported_at': DateTime.now().toIso8601String(),
        'app': AppConfig.appName,
        'shopping_lists': [for (final l in lists) l.toJson()],
        'pantry': [for (final p in pantry) p.toJson()],
        'receipts': [for (final r in receipts) r.toJson()],
        // Plans are stored one row per week; this is the current one.
        'meal_plan_current_week': plan?.toJson(),
        'preferences': preferences.toJson(),
      });

      await Clipboard.setData(ClipboardData(text: export));
      Telemetry.logEvent('data_exported');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Your data is on the clipboard — paste it anywhere'),
        ),
      );
    } catch (e) {
      Telemetry.recordError(e, StackTrace.current);
      messenger.showSnackBar(
        const SnackBar(content: Text('Export failed — try again')),
      );
    }
  }

  Future<void> _sendFeedback(BuildContext context, WidgetRef ref) async {
    // Counts intent; the mail client decides whether anything is sent.
    Telemetry.logEvent('feedback_opened');
    final version = await ref.read(appVersionProvider.future);
    final errors = Telemetry.recentErrors;
    final body = StringBuffer()
      ..writeln('\n\n---')
      ..writeln('App: ${AppConfig.appName} $version')
      ..writeln('Platform: ${PlatformSupport.platformName}')
      ..writeln('Mode: ${AppConfig.isDemoMode ? 'demo' : 'connected'}');
    if (errors.isNotEmpty) {
      body.writeln('Recent errors (${errors.length}):');
      // Newest first — the crash the user is writing about is the last
      // one recorded, not the first.
      for (final e in errors.reversed.take(3)) {
        body.writeln('- $e');
      }
    }
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query:
          'subject=${Uri.encodeComponent('Grocery Assistant feedback ($version)')}'
          '&body=${Uri.encodeComponent(body.toString())}',
    );
    if (!context.mounted) return;
    if (!await launchUrl(uri) && context.mounted) {
      // No mail client (common on desktop): fall back to the clipboard.
      await Clipboard.setData(ClipboardData(text: '$supportEmail\n$body'));
      if (context.mounted) {
        context.showSnack('No mail app — address and details copied');
      }
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      context.showSnack('Could not open link', error: true);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    // One explicit confirmation dialog before the only action in the
    // app that cannot be undone by design.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: Text(
          AppConfig.isDemoMode
              ? 'All demo data on this device — lists, pantry, receipts '
                    'and settings — will be erased. This cannot be undone.'
              : 'Your account and all data — lists, pantry, receipts, '
                    'meal plans and settings — will be permanently deleted '
                    'from our servers. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    // Everything after the first await must not need this widget:
    // deleteAccount() emits the signedOut auth event, the router
    // redirects, and this Settings screen unmounts mid-flow. Capture
    // dependencies now and finish with context-free calls.
    final auth = ref.read(authRepositoryProvider);
    final store = ref.read(localStoreProvider);
    try {
      Telemetry.logEvent('account_deleted', {'demo': AppConfig.isDemoMode});
      await auth.deleteAccount();
      await store.wipe();
      // Full rebuild: providers, caches, auth state, onboarding flag.
      // The router lands on sign-in by itself once auth state is gone.
      AppBootstrap.restartGlobal();
    } on AuthFailure catch (e) {
      Telemetry.recordError(e, StackTrace.current);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      // An expired session cannot delete the account, but leaving the
      // user "signed in" on it strands them: sign out so the router
      // lands on sign-in, where the snack's advice is actionable.
      try {
        await auth.signOut();
      } catch (_) {
        // Best effort — the session is already dead.
      }
    } on Failure catch (e) {
      Telemetry.recordError(e, StackTrace.current);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      Telemetry.recordError(e, StackTrace.current);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Deletion failed — check your connection and retry'),
        ),
      );
    }
  }
}
