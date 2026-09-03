import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/guided_discovery/widgets/discovery_complete_state.dart';

void main() {
  setUpAll(() {
    //disable google fonts
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the end-of-deck summary with swipe counts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(
        DiscoveryCompleteState(
          likedCount: 2,
          dislikedCount: 1,
          skippedCount: 3,
          onReset: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text("That's everything for now"), findsOneWidget);
    expect(find.text('LIKED'), findsOneWidget);
    expect(find.text('PASSED'), findsOneWidget);
    expect(find.text('SKIPPED'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Start Again'), findsOneWidget);
  });

  testWidgets('shows zero counts when nothing was swiped', (tester) async {
    await tester.pumpWidget(
      wrap(
        DiscoveryCompleteState(
          likedCount: 0,
          dislikedCount: 0,
          skippedCount: 0,
          onReset: () {},
        ),
      ),
    );

    // All three stats read zero.
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('LIKED'), findsOneWidget);
  });

  testWidgets('calls onReset when Start Again is tapped', (tester) async {
    var resetCalled = false;

    await tester.pumpWidget(
      wrap(
        DiscoveryCompleteState(
          likedCount: 1,
          dislikedCount: 2,
          skippedCount: 0,
          onReset: () => resetCalled = true,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Start Again'));
    await tester.tap(find.text('Start Again'));

    expect(resetCalled, isTrue);
  });
}