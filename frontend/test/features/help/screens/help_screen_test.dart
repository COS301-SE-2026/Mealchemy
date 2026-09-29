import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/help/screens/help_screen.dart';
import 'package:mealchemy/features/help/widgets/help_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host() {
    final router = GoRouter(
      initialLocation: '/help',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Text('home screen')),
        ),
        GoRoute(
          path: '/help',
          builder: (context, state) => const HelpScreen(),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  Future<void> pumpHelp(
    WidgetTester tester, {
    Size size = const Size(1080, 2400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
  }

  testWidgets('renders the header title', (tester) async {
    await pumpHelp(tester);
    expect(find.text('Help & Support'), findsOneWidget);
  });

  testWidgets('renders the three section headers', (tester) async {
    await pumpHelp(tester);
    expect(find.text('Help Center'), findsOneWidget);
    expect(find.text('Navigation Guide'), findsOneWidget);
    expect(find.text('Frequently Asked'), findsOneWidget);
  });

  testWidgets('renders help rows', (tester) async {
    await pumpHelp(tester);

    expect(find.byType(HelpRow), findsWidgets);
    expect(find.text('Contact Support'), findsOneWidget);
  });

  testWidgets('renders help topics for recently added features', (
    tester,
  ) async {
    await pumpHelp(tester, size: const Size(1080, 4000));

    expect(find.text('Guided Discovery'), findsOneWidget);
    expect(find.text('Understanding Nutrition'), findsOneWidget);
    expect(find.text('Saving External Recipe Links'), findsOneWidget);
    expect(find.text('Using Mealchemy Offline'), findsOneWidget);
    expect(find.text('Cooking step by step'), findsOneWidget);
    expect(find.text('Using cooking timers'), findsOneWidget);
  });

  testWidgets('the cook mode rows expand to show their content', (
    tester,
  ) async {
    await pumpHelp(tester);

    final cookRow = find.text('Cooking step by step');
    await tester.ensureVisible(cookRow);
    await tester.pumpAndSettle();
    await tester.tap(cookRow);
    await tester.pumpAndSettle();
    expect(find.text('Here is your quick tour of Cook Mode:'), findsOneWidget);

    final timerRow = find.text('Using cooking timers');
    await tester.ensureVisible(timerRow);
    await tester.pumpAndSettle();
    await tester.tap(timerRow);
    await tester.pumpAndSettle();
    expect(find.text('Here is how timers work:'), findsOneWidget);
  });
}