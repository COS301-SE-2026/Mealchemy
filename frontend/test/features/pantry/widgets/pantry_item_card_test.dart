import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PantryItemCard renders ingredient details and fresh status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PantryItemCard(
            name: 'Chicken Breast',
            details: '800g • Refrigerated',
            status: PantryItemStatus.fresh,
          ),
        ),
      ),
    );

    expect(find.text('Chicken Breast'), findsOneWidget);
    expect(find.text('800g • Refrigerated'), findsOneWidget);
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
  });

  testWidgets('PantryItemCard shows delete action for expired items', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PantryItemCard(
            name: 'Baby Spinach',
            details: '200g • Expired 2 days ago',
            status: PantryItemStatus.expired,
          ),
        ),
      ),
    );

    expect(find.text('Baby Spinach'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}