import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/preference/widgets/weights_help_sheet.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host() {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showWeightsHelp(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  group('weights help sheet', () {
    testWidgets('opens with the heading and every signal', (tester) async {
      await tester.pumpWidget(host());

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('How recommendations work'), findsOneWidget);
      for (final title in const [
        'Pantry Match',
        'Cuisine',
        'Nutrition',
        'Freshness',
        'Novelty',
      ]) {
        expect(find.text(title), findsOneWidget);
      }
    });
  });
}