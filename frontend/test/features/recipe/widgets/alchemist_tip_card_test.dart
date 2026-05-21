import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/features/recipe/widgets/alchemist_tip_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }

  testWidgets('AlchemistTipCard renders label, lightbulb icon and tip text', (
    tester,
  ) async {
    const tip = 'Toast the saffron in warm stock before adding the rice.';

    await tester.pumpWidget(host(const AlchemistTipCard(tip: tip)));

    expect(find.text("ALCHEMIST'S TIP"), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    expect(find.text(tip), findsOneWidget);
  });

  testWidgets('AlchemistTipCard wraps in an AppCard', (tester) async {
    await tester.pumpWidget(host(const AlchemistTipCard(tip: 'short tip')));

    expect(find.byType(AppCard), findsOneWidget);
  });
}
