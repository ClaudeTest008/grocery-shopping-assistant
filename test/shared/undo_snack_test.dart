import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/theme/app_theme.dart';
import 'package:grocery_shopping_assistant/shared/extensions/context_extensions.dart';

/// Swipe-to-delete without undo is the fastest way to lose a user's
/// data. These pin the affordance itself.
void main() {
  Future<void> pumpHost(
    WidgetTester tester, {
    required VoidCallback onUndo,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () =>
                    context.showUndoSnack('Removed Milk', onUndo: onUndo),
                child: const Text('delete'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('offers an Undo action alongside the message', (tester) async {
    await pumpHost(tester, onUndo: () {});

    await tester.tap(find.text('delete'));
    await tester.pump();

    expect(find.text('Removed Milk'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);
  });

  testWidgets('tapping Undo runs the restore callback', (tester) async {
    var restored = false;
    await pumpHost(tester, onUndo: () => restored = true);

    await tester.tap(find.text('delete'));
    // Let the snack bar finish sliding in, otherwise the action is not
    // yet hit-testable.
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pump();

    expect(restored, isTrue);
  });

  testWidgets('stays on screen long enough to be actionable', (tester) async {
    await pumpHost(tester, onUndo: () {});

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(
      snackBar.duration.inSeconds,
      greaterThanOrEqualTo(5),
      reason: "Flutter's 4s default is too short to notice and react to",
    );
  });
}
