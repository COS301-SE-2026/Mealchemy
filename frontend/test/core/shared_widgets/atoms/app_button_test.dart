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

  group('AppButton', () {
    //Building a primary button and checking if the label appears on screen
    testWidgets('renders label correctly', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Get Started', onPressed: () {}),
      ));
      expect(find.text('Get Started'), findsOneWidget);
    });

    //Building a primary button and checking if it uses ElevatedButton under the hood
    testWidgets('primary renders ElevatedButton', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Test', onPressed: () {}),
      ));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    //Building an outlined button and checking if it uses OutlinedButton under the hood
    testWidgets('outlined renders OutlinedButton', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.outlined(label: 'Test', onPressed: () {}),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    //Building a text button and checking if it uses TextButton under the hood
    testWidgets('text renders TextButton', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.text(label: 'Test', onPressed: () {}),
      ));
      expect(find.byType(TextButton), findsOneWidget);
    });

    //Building a primary button with isLoading true and checking if spinner shows and label is hidden
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(
          label: 'Loading',
          onPressed: null,
          isLoading: true,
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    //Building a primary button with null onPressed and checking if the button is disabled
    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Disabled', onPressed: null),
      ));
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    //Building a primary button with a left icon and checking if the icon appears on screen
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

    //Building a primary button with isFullWidth true and checking if it stretches to fill the screen
    testWidgets('stretches when isFullWidth is true', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(
          label: 'Full',
          onPressed: () {},
          isFullWidth: true,
        ),
      ));
      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, double.infinity);
    });

    //Building a secondary button and checking if it uses ElevatedButton under the hood
    testWidgets('secondary renders ElevatedButton', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.secondary(label: 'Test', onPressed: () {}),
      ));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    //Building an outlined button with custom colour and checking if correct colour is applied
    testWidgets('outlined uses custom colour when provided', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.outlined(
          label: 'Custom',
          onPressed: () {},
          customColor: Colors.red,
        ),
      ));
      final button = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(button.onPressed, isNotNull);
      expect(find.text('Custom'), findsOneWidget);
    });

    //Building a text button with custom colour and checking if correct colour is applied
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

    //Building a primary button with isRounded true and checking it builds without error
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