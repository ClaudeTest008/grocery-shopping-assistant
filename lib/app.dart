import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/data/preferences_repository.dart';

class GroceryApp extends ConsumerWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (prefs.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      routerConfig: router,
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
