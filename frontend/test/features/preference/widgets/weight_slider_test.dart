import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/preference/widgets/weight_slider.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host({
    double value = 0.4,
    ValueChanged<double>? onChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: WeightSlider(
          title: 'Pantry Match',
          icon: Icons.kitchen_outlined,
          subtitle: 'Favour recipes you can make with what you already have',
          value: value,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }

  group('WeightSlider', () {
    testWidgets('rendrs the title and subtitle', (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      expect(find.text('Pantry Match'), findsOneWidget);
      expect(
        find.text('Favour recipes you can make with what you already have'),
        findsOneWidget,
      );
    });

    testWidgets('shows no percentage', (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('dragging the slider reports a new value', (tester) async {
      double? changed;

      await tester.pumpWidget(host(value: 0.5, onChanged: (v) => changed = v));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pump();
      expect(changed, isNotNull);
      expect(changed, greaterThan(0.5));
    });
  });
}