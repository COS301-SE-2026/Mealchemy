import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/help/widgets/help_header.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host() {
    final router = GoRouter(
      initialLocation: '/preference',
      routes: [
        GoRoute(
          path: '/preference',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('PERSONALIZED CURATION'),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () => context.push('/help'),
                  ),
                ],
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/help',
          builder: (context, state) => const Scaffold(body: HelpHeader()),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders the title and back button', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
  });

  testWidgets('tapping back pops to the preference screen', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

  
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('Help & Support'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.text('PERSONALIZED CURATION'), findsOneWidget);
    expect(find.text('Help & Support'), findsNothing);
  });
}