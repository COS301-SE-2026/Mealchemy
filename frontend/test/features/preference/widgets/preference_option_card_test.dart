import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/preference/widgets/preference_option_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PreferenceOptionCard renders selected option state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PreferenceOptionCard(
            title: 'CELIAC FRIENDLY / GLUTEN-FREE',
            subtitle: 'Rigorous gluten-free adherence.',
            selected: true,
          ),
        ),
      ),
    );

    expect(find.text('CELIAC FRIENDLY / GLUTEN-FREE'), findsOneWidget);
    expect(find.text('Rigorous gluten-free adherence.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('PreferenceOptionCard calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PreferenceOptionCard(
            title: 'DAIRY FREE',
            subtitle: 'Lactose and casein-free alternatives.',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('DAIRY FREE'));
    expect(tapped, isTrue);
  });
}