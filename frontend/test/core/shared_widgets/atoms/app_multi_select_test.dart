import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mealchemy/core/shared_widgets/atoms/app_multi_select.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  for (final alignment in [
    Alignment.topLeft,
    Alignment.topRight,
  ]) {
    testWidgets('equipment menu stays on screen at $alignment', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: alignment,
                child: const SizedBox(
                  width: 170,
                  child: SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: alignment,
                child: SizedBox(
                  width: 170,
                  child: AppMultiSelect(
                    addLabel: 'Add equipment',
                    options: const [
                      MultiSelectOption(
                        value: 'FOOD_PROCESSOR',
                        label: 'Food processor',
                      ),
                      MultiSelectOption(
                        value: 'OVEN',
                        label: 'Oven',
                      ),
                    ],
                    selectedValues: const [],
                    onToggle: (value) => selected = value,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add equipment'));
      await tester.pumpAndSettle();

      final menu = tester.getRect(
        find.byKey(const ValueKey('multi-select-menu')),
      );

      expect(menu.left, greaterThanOrEqualTo(12));
      expect(menu.right, lessThanOrEqualTo(378));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Food processor'));
      await tester.pump();

      expect(selected, 'FOOD_PROCESSOR');
    });
  }
}
