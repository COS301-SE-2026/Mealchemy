import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/help/widgets/help_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host({
    IconData icon = Icons.mail_outline_rounded,
    String title = 'Contact Support',
    List<Widget> body = const [Text('Body content here')],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: HelpRow(icon: icon, title: title, body: body),
        ),
      ),
    );
  }

  testWidgets('renders the title and leading icon', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Contact Support'), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
  });


  testWidgets('body is hidden until the row is tapped', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    final bodyFinder = find.text('Body content here');
    expect(
      tester.getSize(find.byType(AnimatedCrossFade)).height,
      lessThan(20),
    );

    await tester.tap(find.text('Contact Support'));
    await tester.pumpAndSettle();
    expect(bodyFinder, findsOneWidget);
  });

  testWidgets('chevron rotates when expanded', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    AnimatedRotation rotation() =>
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));

    expect(rotation().turns, 0.0);
    await tester.tap(find.text('Contact Support'));
    await tester.pumpAndSettle();
    expect(rotation().turns, 0.5);
  });

  testWidgets('tapping again collapses the row', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contact Support'));
    await tester.pumpAndSettle();
    expect(find.text('Body content here'), findsOneWidget);
    await tester.tap(find.text('Contact Support'));
    await tester.pumpAndSettle();
    final rotation =
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
    expect(rotation.turns, 0.0);
  });
}
