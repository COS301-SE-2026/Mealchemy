import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/features/cook_mode/models/cook_session.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_session_provider.dart';
import 'package:mealchemy/features/dashboard/widgets/continue_cooking_row.dart';

Widget _host(CookSession? session) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: ContinueCookingRow()),
      ),
      GoRoute(
        path: '/recipe/:id/cook',
        builder: (_, __) => const Scaffold(body: Text('Cook screen')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      latestCookSessionProvider.overrideWith((ref) async => session),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  final saved = CookSession(
    recipeId: 7,
    recipeTitle: 'Weeknight Pasta',
    stepIndex: 1,
    stepNumber: 2,
    stepText: 'Add sauce.',
    stepCount: 3,
    savedAt: DateTime.utc(2026, 9, 13),
  );

  testWidgets('shows the latest progress and opens Cook Mode', (tester) async {
    await tester.pumpWidget(_host(saved));
    await tester.pumpAndSettle();

    expect(find.text('Continue cooking'), findsOneWidget);
    expect(find.text('Weeknight Pasta, Step 2 of 3'), findsOneWidget);

    await tester.tap(find.text('Continue cooking'));
    await tester.pumpAndSettle();
    expect(find.text('Cook screen'), findsOneWidget);
  });

  testWidgets('shows no resume row without saved progress', (tester) async {
    await tester.pumpWidget(_host(null));
    await tester.pumpAndSettle();

    expect(find.text('Continue cooking'), findsNothing);
  });
}
