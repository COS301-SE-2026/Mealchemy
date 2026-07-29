import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/repositories/mock_dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_pantry_card.dart';

class _TestDashboardNotifier extends DashboardNotifier {
  _TestDashboardNotifier(DashboardState fixedState)
      : super(MockDashboardRepository()) {
    state = fixedState;
  }
}

void main() {
  Widget buildTestHarness({required int pantryItemCount}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: DashboardPantryCard()),
        ),
        GoRoute(
          path: AppRoutes.addIngredient,
          builder: (context, state) =>
              const Scaffold(body: Text('Add Ingredient Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        dashboardProvider.overrideWith(
          (ref) => _TestDashboardNotifier(
            DashboardState(pantryItemCount: pantryItemCount),
          ),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('displays the pantry item coun  and label', (tester) async {
    await tester.pumpWidget(buildTestHarness(pantryItemCount: 5));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('IN YOUR PANTRY'), findsOneWidget);
  });

  testWidgets('renders 3 preview icon circles ', (tester) async {
    await tester.pumpWidget(buildTestHarness(pantryItemCount: 5));
    expect(find.byIcon(Icons.cookie_outlined), findsOneWidget);
    expect(find.byIcon(Icons.egg_outlined), findsOneWidget);
    expect(find.byIcon(Icons.apple_outlined), findsOneWidget);
  });

  testWidgets(' shows remaining count badge when pantry has more than 3 items',
      (tester) async {
    await tester.pumpWidget(buildTestHarness(pantryItemCount: 5));
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('hides remaining count badge when pantry has 3 or fewer items',
      (tester) async {
    await tester.pumpWidget(buildTestHarness(pantryItemCount: 3));

    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('tapping the add button navigates to add ingredient screen',
      (tester) async {
    await tester.pumpWidget(buildTestHarness(pantryItemCount: 5));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Add Ingredient Screen'), findsOneWidget);
  });
}
