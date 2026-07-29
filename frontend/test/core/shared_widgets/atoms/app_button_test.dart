import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/theme/app_theme.dart';

void main() {
  Widget buildButton(Widget button) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: button)),
    );
  }

  InkWell inkWellOf(WidgetTester tester) =>
      tester.widget<InkWell>(find.byType(InkWell));

  group('AppButton', () {
    //Building a primary button and checking if the label appears on screen
    testWidgets('renders label correctly', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Get Started', onPressed: () {}),
      ));
      expect(find.text('Get Started'), findsOneWidget);
    });

    //Building each variant and checking it renders an InkWell with its label
    testWidgets('every variant renders an InkWell and its label',
        (tester) async {
      for (final button in [
        AppButton.primary(label: 'P', onPressed: () {}),
        AppButton.secondary(label: 'S', onPressed: () {}),
        AppButton.outlined(label: 'O', onPressed: () {}),
        AppButton.text(label: 'T', onPressed: () {}),
      ]) {
        await tester.pumpWidget(buildButton(button));
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.text(button.label), findsOneWidget);
      }
    });

    //Building an enabled button and checking the tap callback fires
    testWidgets('tapping an enabled button fires onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Tap', onPressed: () => tapped = true),
      ));
      await tester.tap(find.text('Tap'));
      expect(tapped, isTrue);
    });

    //Building a primary button with isLoading true and cheking the spinner shows and label hides
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Loading', onPressed: null, isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    //Building a primary button with null onPressed and checking the inkwell tap is null
    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Disabled', onPressed: null),
      ));
      expect(inkWellOf(tester).onTap, isNull);
    });

    //Building a primary button with a left icon and checking the icon appears
    testWidgets('shows left icon when provided', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(
          label: 'Scan',
          onPressed: () {},
          leftIcon: Icons.camera_alt,
        ),
      ));
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    //Building a primary button with a right icon and checking the icon appears
    testWidgets('shows right icon when provided', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(
          label: 'Next',
          onPressed: () {},
          rightIcon: Icons.arrow_forward,
        ),
      ));
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    //Building an outlined button and cheking it draws a border (only outlined does)
    testWidgets('outlined renders a border', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.outlined(label: 'Bordered', onPressed: () {}),
      ));
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final hasBorder = containers.any((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.border != null;
      });
      expect(hasBorder, isTrue);
    });

    //Building a primary button with isFullWidth true and checking it strethes to fill
    testWidgets('stretches when isFullWidth is true', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Full', onPressed: () {}, isFullWidth: true),
      ));
      final widths = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .map((s) => s.width)
          .toList();
      expect(widths, contains(double.infinity));
    });

    //Building an outlined button with custom colour and checking it builds fine
    testWidgets('outlined uses custom colour when provided', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.outlined(
          label: 'Custom',
          onPressed: () {},
          customColor: Colors.red,
        ),
      ));
      expect(find.text('Custom'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    //Building a text button with custom colour and checking it builds fine
    testWidgets('text uses custom colour when provided', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.text(
          label: 'Custom',
          onPressed: () {},
          customColor: Colors.green,
        ),
      ));
      expect(find.text('Custom'), findsOneWidget);
    });

    //Building a rounded full width button and checking it builds without error
    testWidgets('renders rounded correctly', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(
          label: 'Rounded',
          onPressed: () {},
          isRounded: true,
          isFullWidth: true,
        ),
      ));
      expect(find.text('Rounded'), findsOneWidget);
    });
  });
}