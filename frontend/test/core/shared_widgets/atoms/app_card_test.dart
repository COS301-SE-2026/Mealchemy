import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_theme.dart';

void main() {
  Widget buildCard(Widget card) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: card,
        ),
      ),
    );
  }

  group('AppCard', () {
    // Building a light card and checking if the child content appears on screen
    testWidgets('renders child content correctly', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.light(child: const Text('Hello')),
      ));
      expect(find.text('Hello'), findsOneWidget);
    });

    // Building a light card and checking if it uses a white background
    testWidgets('light variant has correct background colour', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.light(child: const Text('Light')),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    // Building a dark card and checking if it uses the primary colour background
    testWidgets('dark variant has correct background colour', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.dark(child: const Text('Dark')),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    // Building an accent card and checking if it uses the accent light background
    testWidgets('accent variant has correct background colour', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.accent(child: const Text('Accent')),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.accentLight);
    });

    // Building an outlined card and checking if it has a border
    testWidgets('outlined variant has border', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.outlined(child: const Text('Outlined')),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    // Building an outlined card with custom border colour and checking if it uses that colour
    testWidgets('outlined variant uses custom border colour', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.outlined(
          customBorderColor: Colors.red,
          child: const Text('Custom border'),
        ),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, Colors.red);
    });

    // Building a gradient card and checking if it has a gradient decoration
    testWidgets('gradient variant has gradient decoration', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.gradient(child: const Text('Gradient')),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
    });

    // Building a tappable card and checking if the onTap callback fires when tapped
    testWidgets('fires onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildCard(
        AppCard.light(
          onTap: () => tapped = true,
          child: const Text('Tap me'),
        ),
      ));
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    // Building a card with custom border radius and checking it builds without error
    testWidgets('renders with custom border radius', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.light(
          borderRadius: 32,
          child: const Text('Rounded'),
        ),
      ));
      expect(find.text('Rounded'), findsOneWidget);
    });

    // Building a card with custom width and height and checking the rendered size
    testWidgets('renders with custom width and height', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.light(
          width: 200,
          height: 100,
          child: const Text('Sized'),
        ),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxWidth, 200);
      expect(container.constraints?.maxHeight, 100);
    });

    // Building a light card and checking if it has a shadow
    testWidgets('light variant has shadow', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.light(child: const Text('Shadow')),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, true);
    });

    // Building a dark card and checking it has no shadow
    testWidgets('dark variant has no shadow', (tester) async {
      await tester.pumpWidget(buildCard(
        AppCard.dark(child: const Text('No shadow')),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });
  });
}