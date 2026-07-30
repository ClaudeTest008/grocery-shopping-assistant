import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/theme/app_theme.dart';
import 'package:grocery_shopping_assistant/features/home/presentation/onboarding_screen.dart';

/// Onboarding is the first thing a new user (and every demo visitor)
/// sees, so it has to lay out cleanly at desktop window sizes as well as
/// on phones.
void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final sizes = <String, Size>{
    'phone': const Size(390, 844),
    'windows default window': const Size(1280, 800),
    'minimum window': const Size(640, 560),
    'short landscape': const Size(1280, 600),
  };

  for (final entry in sizes.entries) {
    testWidgets('lays out without overflow at ${entry.key}', (tester) async {
      await pumpAt(tester, entry.value);

      expect(tester.takeException(), isNull);
      expect(find.text('One list. The cheapest trip.'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  }
}
