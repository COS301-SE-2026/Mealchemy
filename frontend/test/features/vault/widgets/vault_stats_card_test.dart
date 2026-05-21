import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/vault/widgets/vault_stats_card.dart';

void main() {
  Widget buildWidget() {
    return MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: VaultStatsCard(
          totalRecipes: 10,
          createdPercent: 84,
          categoryCount: 6,
          optimizationPercent: 72,
        ),
      ),
    );
  }

  group('VaultStatsCard', () {
    //testing value and label rendering
    // recipes value
    testWidgets('renders total recipes value', (tester) async {
      await tester.pumpWidget( buildWidget());
      expect(find.text('10'), findsOneWidget);
    });

    //TOTAL RECIPES
    testWidgets('renders TOTAL RECIPES label', (tester) async {
      await tester.pumpWidget(buildWidget( ));
      expect(find.text('TOTAL RECIPES'), findsOneWidget);
    });

    //optimization percentage 
    testWidgets('renders optimization percentage',  (tester) async {
      await tester.pumpWidget(buildWidget());

       expect(find.text('72%' ), findsOneWidget);
    });

    //progress bar 
    testWidgets('renders progress bar', (tester) async {
      await tester.pumpWidget(buildWidget() );
      expect(find.byType(LinearProgressIndicator),  findsOneWidget);
    });
  });
}
