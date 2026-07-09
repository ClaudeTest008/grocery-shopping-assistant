import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/core/theme/app_theme.dart';
import 'package:grocery_shopping_assistant/shared/widgets/empty_state.dart';
import 'package:grocery_shopping_assistant/shared/widgets/price_tag.dart';
import 'package:grocery_shopping_assistant/shared/widgets/section_header.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('EmptyState renders title, message and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        EmptyState(
          icon: Icons.checklist_rounded,
          title: 'No lists yet',
          message: 'Create your first list',
          actionLabel: 'Create',
          onAction: () => tapped = true,
        ),
      ),
    );

    expect(find.text('No lists yet'), findsOneWidget);
    expect(find.text('Create your first list'), findsOneWidget);
    await tester.tap(find.text('Create'));
    expect(tapped, isTrue);
  });

  testWidgets('PriceTag shows deal strikethrough only for real deals', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            PriceTag(price: 2.57, originalPrice: 3.29),
            PriceTag(price: 4.99),
          ],
        ),
      ),
    );

    expect(find.text(r'$2.57'), findsOneWidget);
    expect(find.text(r'$3.29'), findsOneWidget); // strikethrough original
    expect(find.text(r'$4.99'), findsOneWidget);
  });

  testWidgets('SectionHeader action fires', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        SectionHeader(
          title: 'Deals near you',
          actionLabel: 'See all',
          onAction: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('See all'));
    expect(tapped, isTrue);
  });
}
