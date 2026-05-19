import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/preference/screens/preference_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PreferenceScreen renders preference overview', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PreferenceScreen(),
      ),
    );

    expect(find.text('Bespoke Culinary\nProfile'), findsOneWidget);
    expect(find.text('Dietary Directives'), findsOneWidget);
    expect(find.text('PLANT-BASED / VEGAN'), findsOneWidget);
    expect(find.text('CELIAC FRIENDLY / GLUTEN-FREE'), findsOneWidget);
  });
}