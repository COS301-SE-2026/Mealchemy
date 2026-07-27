import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/ingredient_catalogue_item.dart';
import 'package:mealchemy/features/recipe/models/unit_of_measurement.dart';
import 'package:mealchemy/features/recipe/widgets/ingredient_editor_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const units = [
    UnitOfMeasurement(unitId: 1, name: 'g', system: 'METRIC'),
    UnitOfMeasurement(unitId: 2, name: 'tbsp', system: null),
  ];

  const chicken =
      IngredientCatalogueItem(ingId: 7, name: 'Chicken', category: 'Meat');

  Future<void> pumpRow(
    WidgetTester tester, {
    IngredientCatalogueItem? selectedItem,
    TextEditingController? quantityController,
    String? selectedUnit,
    ValueChanged<String?>? onUnitChanged,
    VoidCallback? onRemove,
    bool showError = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: IngredientEditorRow(
              selectedItem: selectedItem,
              quantityController: quantityController ?? TextEditingController(),
              units: units,
              selectedUnit: selectedUnit,
              onUnitChanged: onUnitChanged ?? (_) {},
              onItemSelected: (_) {},
              onRemove: onRemove ?? () {},
              showError: showError,
            ),
          ),
        ),
      ),
    );
  }


  testWidgets('shows the search placeholdr when no ingredient is selected',
      (tester) async {
    await pumpRow(tester);
    expect(find.text('Search ingredient'), findsOneWidget);
  });
  testWidgets('shows the selected ingredient name, bound to the model',
      (tester) async {
    await pumpRow(tester, selectedItem: chicken);
    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('Search ingredient'), findsNothing);
  });
  testWidgets('unit dropdown lists the provided units and reports selection',
      (tester) async {
    String? changedTo;
    await pumpRow(tester, onUnitChanged: (v) => changedTo = v);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('g'), findsWidgets);
    expect(find.text('tbsp'), findsWidgets);

    await tester.tap(find.text('tbsp').last);
    await tester.pumpAndSettle();
    expect(changedTo, 'tbsp');
  });

  testWidgets('typing routes through the quantity controller', (tester) async {
    final qty = TextEditingController();
    await pumpRow(tester, quantityController: qty);

    await tester.enterText(find.widgetWithText(TextField, 'Qty'), '250');
    expect(qty.text, '250');
  });

  testWidgets('tapping remove fires onRemove', (tester) async {
    var removed = false;
    await pumpRow(tester, onRemove: () => removed = true);

    await tester.tap(find.byTooltip('Remove'));
    expect(removed, isTrue);
  });

  testWidgets('error text is shown only when showError is true',
      (tester) async {
    const message = 'Pick an ingredient and enter quantity + unit.';

    await pumpRow(tester, showError: false);
    expect(find.text(message), findsNothing);

    await pumpRow(tester, showError: true);
    expect(find.text(message), findsOneWidget);
  });
}
