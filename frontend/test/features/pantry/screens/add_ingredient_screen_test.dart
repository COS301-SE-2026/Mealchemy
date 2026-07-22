import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
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

  testWidgets('AddIngredientScreen renders sheet title and  form fields', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    expect(find.text('Pantry Entry'), findsOneWidget);
    expect(find.text('Add Ingredient Manually'), findsOneWidget);
    expect(find.text('Ingredient Details'), findsOneWidget);
    expect(find.text('Ingredient Name'), findsOneWidget);
    expect(find.text('Unit'), findsOneWidget);
    expect(find.text('Save Ingredient'), findsOneWidget);
  });

  testWidgets('AddIngredientScreen validates required fields on save', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    // First AppButton is the save action.
    await tester.tap(find.text('Save Ingredient'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ingredient name is required.', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Unit is required.', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('AddIngredientScreen quantity stepper increments and floors at 1 ', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    //starts at 1 and the minus button does nothing at the floor
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    //last Icons.add is the stepper plus (first is the header button)
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });

    testWidgets('AddIngredientScreen selects a unit from the dropdown', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);
 
    await tester.tap(find.text('e.g. oz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('g').last);
    await tester.pumpAndSettle();
 
    expect(find.text('g'), findsOneWidget);
  });
}
