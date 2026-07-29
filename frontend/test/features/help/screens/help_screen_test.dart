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

  testWidgets('renders the header title', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Help & Support'), findsOneWidget);
  });

  testWidgets('renders the three section headers', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('Help Center'), findsOneWidget);
    expect(find.text('Navigation Guide'), findsOneWidget);
    expect(find.text('Frequently Asked'), findsOneWidget);
  });

  testWidgets('renders help rows', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byType(HelpRow), findsWidgets);
    expect(find.text('Contact Support'), findsOneWidget);
  });

  testWidgets('a row expands to reveal its body when tapped', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contact Support'));
    await tester.pumpAndSettle();

    expect(find.text('pulsefve@gmail.com'), findsWidgets);
  });
}