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
    testWidgets('renders label correctly', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Get Started', onPressed: () {}),
      ));
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('primary renders ElevatedButton', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Test', onPressed: () {}),
      ));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('outlined renders OutlinedButton', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.outlined(label: 'Test', onPressed: () {}),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('text renders TextButton', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.text(label: 'Test', onPressed: () {}),
      ));
      expect(find.byType(TextButton), findsOneWidget);
    });

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

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.primary(label: 'Disabled', onPressed: null),
      ));
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

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

    testWidgets('secondary renders ElevatedButton', (tester) async {
      await tester.pumpWidget(buildButton(
        AppButton.secondary(label: 'Test', onPressed: () {}),
      ));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}