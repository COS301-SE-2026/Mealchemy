import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_cards_row.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_pantry_card.dart';
import 'package:mealchemy/features/dashboard/widgets/smart_suggestion_card.dart';

void main() {
  Widget buildTestableWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: DashboardCardsRow(),
        ),
      ),
    );
  }

  testWidgets('renders DashboardPantryCard and SmartSuggestionCard correctly',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.byType(DashboardCardsRow), findsOneWidget);
    expect(find.byType(DashboardPantryCard), findsOneWidget);
    expect(find.byType(SmartSuggestionCard), findsOneWidget);
  });

}