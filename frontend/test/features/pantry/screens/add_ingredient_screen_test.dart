import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/features/pantry/screens/add_ingredient_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpAddIngredientScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      //need provider scope because screen reads Riverpod providers
      const ProviderScope(
        child: MaterialApp(
          home: AddIngredientScreen(),
        ),
      ),
    );

    //waits for mock data to load
    await tester.pumpAndSettle();
  }

  testWidgets('AddIngredientScreen renders manual ingredient form', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    expect(find.text('Add Ingredient\nManually'), findsOneWidget);
    expect(find.text('Ingredient Details'), findsOneWidget);
    expect(find.text('Ingredient name'), findsOneWidget);
    expect(find.text('Quantity'), findsWidgets);
  });

  testWidgets('AddIngredientScreen validates required fields on save', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    // First AppButton is the save action.
    await tester.tap(find.byType(AppButton).first);
    await tester.pumpAndSettle();

    expect(
      find.text('Ingredient name is required.', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Quantity and unit are required.', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('AddIngredientScreen updates category and stock controls', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    await tester.tap(find.text('DAIRY'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as out of stock'));
    await tester.pumpAndSettle();

    expect(find.text('DAIRY'), findsOneWidget);
    expect(find.text('Mark as out of stock'), findsOneWidget);
  });
}