import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_queue_provider.dart';
import 'package:mealchemy/features/admin/widgets/admin_flag_card.dart';
import 'package:mealchemy/features/admin/widgets/admin_queue_section.dart';

FlaggedRecipe _flag() => FlaggedRecipe(
      flaggedId: 12,
      recipeId: 87,
      recipeTitle: 'Spicy Chicken Ramen',
      flaggedByUserId: 4,
      reasonValue: 'SPAM_MISLEADING',
      reasonLabel: 'Spam / misleading',
      status: FlagStatus.pending,
      flaggedAt: DateTime.utc(2026, 9, 19, 13),
    );

Widget _host(
  Future<List<FlaggedRecipe>> Function(FlagStatus) load,
) {
  return ProviderScope(
    overrides: [
      adminQueueProvider.overrideWith((ref, status) => load(status)),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: AdminQueueSection(),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows loading until reports arrive', (tester) async {
    final pending = Completer<List<FlaggedRecipe>>();
    await tester.pumpWidget(_host((_) => pending.future));

    expect(find.text('Loading reports…'), findsOneWidget);
    expect(find.byType(AdminFlagCard), findsNothing);

    pending.complete([_flag()]);
    await tester.pumpAndSettle();

    expect(find.text('Loading reports…'), findsNothing);
    expect(find.text('Spicy Chicken Ramen'), findsOneWidget);
    expect(find.text('Spam / misleading'), findsOneWidget);
    expect(find.text('Reported by user #4'), findsOneWidget);
    expect(find.text('Report #12 · Pending'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
  });

  testWidgets('filters show their corresponding empty states', (tester) async {
    final calls = <FlagStatus>[];

    await tester.pumpWidget(
      _host((status) async {
        calls.add(status);
        return [];
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('No pending reports.'), findsOneWidget);

    await tester.tap(find.text('Reviewed'));
    await tester.pumpAndSettle();
    expect(find.text('No reviewed reports.'), findsOneWidget);
    expect(find.text('No pending reports.'), findsNothing);

    await tester.tap(find.text('Removed'));
    await tester.pumpAndSettle();
    expect(find.text('No removed reports.'), findsOneWidget);

    expect(
      calls,
      [FlagStatus.pending, FlagStatus.reviewed, FlagStatus.removed],
    );
  });

  testWidgets('late result from another filter stays hidden', (tester) async {
    final pending = Completer<List<FlaggedRecipe>>();

    await tester.pumpWidget(
      _host(
        (status) =>
            status == FlagStatus.pending ? pending.future : Future.value([]),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Reviewed'));
    await tester.pumpAndSettle();

    pending.complete([_flag()]);
    await tester.pumpAndSettle();

    expect(find.text('No reviewed reports.'), findsOneWidget);
    expect(find.text('Spicy Chicken Ramen'), findsNothing);
  });

  testWidgets('retry recovers from a queue error', (tester) async {
    var calls = 0;

    await tester.pumpWidget(
      _host((_) async {
        calls++;
        if (calls == 1) throw Exception('failed');
        return [_flag()];
      }),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load reports. Please try again.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry reports'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Spicy Chicken Ramen'), findsOneWidget);
  });

  testWidgets('permission failure shows no report data', (tester) async {
    await tester.pumpWidget(
      _host((_) async {
        throw const AdminQueueAccessException(AdminAccess.forbidden);
      }),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AdminFlagCard), findsNothing);
    expect(
      find.text('Your account does not have administrator access.'),
      findsOneWidget,
    );
  });
}
