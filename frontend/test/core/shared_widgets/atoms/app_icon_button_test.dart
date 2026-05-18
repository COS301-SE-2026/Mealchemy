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
    //Building a primary button and checking if it's icon appers on screen
    testWidgets('renders icon correctly', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(icon: Icons.favorite, onPressed: () {}),
      ));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
    //Building a secondary button and checking if it's icon appers on screen
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
    //Building a primary button and checking if it's icon appers on screen and if it is disabled when onPressed is null
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
//Building a primary button and checking if it fires onTap when tapped
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
//Building a primary button and checking if it is the correct size
    testWidgets('is correct size', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(
          icon: Icons.favorite,
          onPressed: () {},
          size: 64,
        ),
      ));
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(GestureDetector),
      );
      expect(renderBox.size.width, 64);
      expect(renderBox.size.height, 64);
    });
//Building a primary button and checking if it has gradient background
    testWidgets('primary renders with gradient', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.primary(icon: Icons.favorite, onPressed: () {}),
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

//Building a ghost button and checking if it has transparent background
    testWidgets('ghost variant has transparent background', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.ghost(icon: Icons.favorite, onPressed: () {}),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);
    });

//Building a ghost button and checking if it has transparent background and correct icon color
    testWidgets('ghost renders icon correctly', (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.ghost(icon: Icons.bookmark, onPressed: () {}),
      ));
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });
//Building an outlined button with custom colour and checking if it has correct border colour
    testWidgets('outlined with custom colour has correct border',
        (tester) async {
      await tester.pumpWidget(buildButton(
        AppIconButton.outlined(
          icon: Icons.share,
          onPressed: () {},
          customColor: Colors.red,
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
  });
}
