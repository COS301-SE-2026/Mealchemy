import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/preference/widgets/flavour_profile_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('FlavourProfileCard renders selected profile details', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlavourProfileCard(
            label: 'Mediterranean',
            description: 'Bright herbs and fresh vegetables.',
            icon: Icons.local_florist_outlined,
            selected: true,
          ),
        ),
      ),
    );

    expect(find.text('MEDITERRANEAN'), findsOneWidget);
    expect(find.text('Bright herbs and fresh vegetables.'), findsOneWidget);
    expect(find.byIcon(Icons.local_florist_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('FlavourProfileCard calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlavourProfileCard(
            label: 'Fresh & Light',
            description: 'Lean proteins and crisp produce.',
            icon: Icons.eco_outlined,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('FRESH & LIGHT'));
    expect(tapped, isTrue);
  });
}