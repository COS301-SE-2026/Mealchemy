import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_stat_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }

  testWidgets('RecipeStatCard renders icon, value and label', (tester) async {
    await tester.pumpWidget(
      host(
        const RecipeStatCard(
          icon: Icons.access_time,
          value: '15m',
          label: 'Prep time',
        ),
      ),
    );

    expect(find.byIcon(Icons.access_time), findsOneWidget);
    expect(find.text('15m'), findsOneWidget);
    expect(find.text('Prep time'), findsOneWidget);
  });

  testWidgets('RecipeStatCard wraps an outlined AppCard', (tester) async {
    await tester.pumpWidget(
      host(
        const RecipeStatCard(
          icon: Icons.local_fire_department_outlined,
          value: '30m',
          label: 'Cook time',
        ),
      ),
    );

    expect(find.byType(AppCard), findsOneWidget);
  });
}
