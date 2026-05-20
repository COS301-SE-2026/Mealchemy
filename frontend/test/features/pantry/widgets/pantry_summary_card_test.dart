import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_summary_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PantrySummaryCard renders pantry metrics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PantrySummaryCard(
            totalItems: 42,
            freshnessPercent: 84,
            categoryCount: 6,
            optimizationPercent: 72,
          ),
        ),
      ),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.text('84%'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
    expect(find.text('Meal Optimization'), findsOneWidget);
  });
}