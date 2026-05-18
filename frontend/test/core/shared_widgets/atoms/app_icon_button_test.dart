import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/theme/app_theme.dart';

void main() {
  Widget buildButton(Widget button) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: button)),
    );
  }

  group('AppIconButton', () {
    testWidgets('renders icon correctly', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(icon: Icons.favorite, onPressed: () {}),
      ));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(
          icon: Icons.favorite,
          onPressed: null,
          isLoading: true,
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('does not fire onTap when loading', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(
          icon: Icons.favorite,
          onPressed: () => tapped = true,
          isLoading: true,
        ),
      ));
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, false);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(
          icon: Icons.favorite,
          onPressed: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets('is correct size', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(
          icon: Icons.favorite,
          onPressed: () {},
          size: 64,
        ),
      ));
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, 64);
    });

    testWidgets('primary renders with gradient', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(icon: Icons.favorite, onPressed: () {}),
      ));
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
    });

    testWidgets('ghost variant has transparent background', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.primaryGhost(icon: Icons.favorite, onPressed: () {}),
      ));
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);
    });

    testWidgets('outlined variant has border', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.outlined(icon: Icons.favorite, onPressed: () {}),
      ));
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('secondaryGhost renders correctly', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.secondaryGhost(icon: Icons.bookmark, onPressed: () {}),
      ));
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('outlinedSecondary has gold border', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.outlinedSecondary(
          icon: Icons.bookmark,
          onPressed: () {},
        ),
      ));
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}