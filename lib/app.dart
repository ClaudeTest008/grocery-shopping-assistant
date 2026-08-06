import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/demo/demo_seed.dart';
import 'core/geo/countries.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/data/preferences_repository.dart';
import 'features/shopping_lists/data/shopping_list_repositories.dart';

/// Flutter omits [PointerDeviceKind.mouse] from drag devices by default,
/// which leaves desktop users unable to drag horizontal carousels or the
/// onboarding pager. Allowing mouse drags makes those surfaces behave the
/// way desktop users expect, without affecting touch platforms.
class _DesktopScrollBehavior extends MaterialScrollBehavior {
  const _DesktopScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class GroceryApp extends ConsumerWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final router = ref.watch(routerProvider);
    // Keeps the offline outbox listening for the connection to return.
    ref.watch(pendingOpsSyncProvider);
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: prefs.highContrast),
      darkTheme: AppTheme.dark(highContrast: prefs.highContrast),
      themeMode: switch (prefs.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      routerConfig: router,
      scrollBehavior: const _DesktopScrollBehavior(),
      // Material/Cupertino chrome (date pickers, tooltips, semantics
      // labels) localizes to the selected country's language; dates and
      // numbers follow via Intl.defaultLocale (set in SelectedCountry).
      // The framework is RTL-ready by construction — a future RTL
      // locale needs only its delegate, no layout work.
      locale: Locale(DemoSeed.country.primaryLanguage),
      supportedLocales: [
        for (final language in {for (final c in Countries.all) ...c.languages})
          Locale(language),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Accessibility: user-controlled text scaling on top of the
        // system setting, clamped to keep layouts usable.
        final mq = MediaQuery.of(context);
        final combined = (mq.textScaler.scale(1.0) * prefs.textScale).clamp(
          0.8,
          2.2,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(combined)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
