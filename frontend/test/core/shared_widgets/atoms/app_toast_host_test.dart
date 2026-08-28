import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/providers/feedback_provider.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_toast_host.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<WidgetRef> pumpHost(WidgetTester tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return const AppToastHost(
                child: Scaffold(body: SizedBox.shrink()),
              );
            },
          ),
        ),
      ),
    );
    return capturedRef;
  }

  testWidgets('a raised toast appears in the tree', (tester) async {
    final ref = await pumpHost(tester);

    ref.read(feedbackProvider.notifier).showShort('Saved to My Recipes');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Saved to My Recipes'), findsOneWidget);
  });

  testWidgets('an actionless toast auto dismisses after the timeout',
      (tester) async {
    final ref = await pumpHost(tester);

    ref.read(feedbackProvider.notifier).showShort('Transient message');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Transient message'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Transient message'), findsNothing);
  });

  testWidgets('a toast with an action stays and  fires its callback',
      (tester) async {
    final ref = await pumpHost(tester);
    var tapped = false;

    ref.read(feedbackProvider.notifier).showLong(
          'Shopping list created',
          actionLabel: 'View',
          onAction: () => tapped = true,
        );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Shopping list created'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);

    await tester.tap(find.text('View'));
    await tester.pump();

    expect(tapped, isTrue);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Shopping list created'), findsNothing);
  });
}
