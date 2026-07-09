import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/main.dart' as app;
import 'package:integration_test/integration_test.dart';

/// Boots the real app in demo mode and walks the primary flow.
/// Run on a device/emulator:
///   flutter test integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots into home and navigates the shell', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Demo mode signs in automatically -> home greeting.
    expect(find.textContaining('Hi,'), findsOneWidget);

    // Bottom navigation reaches every branch.
    await tester.tap(find.text('Lists'));
    await tester.pumpAndSettle();
    expect(find.text('Shopping lists'), findsOneWidget);

    await tester.tap(find.text('Stores'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
  });
}
