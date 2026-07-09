@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/theme/app_theme.dart';
import 'package:grocery_shopping_assistant/shared/widgets/empty_state.dart';

/// Golden baseline for the shared empty state, light and dark.
/// Regenerate with: flutter test --update-goldens test/golden
void main() {
  Widget host(ThemeData theme) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: const Scaffold(
      body: EmptyState(
        icon: Icons.shopping_basket_rounded,
        title: 'No lists yet',
        message: 'Create a list and let the optimizer plan your trip.',
      ),
    ),
  );

  testWidgets('EmptyState golden (light)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    await tester.pumpWidget(host(AppTheme.light()));
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/empty_state_light.png'),
    );
  });

  testWidgets('EmptyState golden (dark)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    await tester.pumpWidget(host(AppTheme.dark()));
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/empty_state_dark.png'),
    );
  });
}
