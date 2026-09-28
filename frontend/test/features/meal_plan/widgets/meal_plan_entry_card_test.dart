import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan_entry.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';
import 'package:mealchemy/features/meal_plan/widgets/meal_plan_entry_card.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

MealPlanEntry _entry({
  String? title,
  MealEntrySource source = MealEntrySource.manual,
}) =>
    MealPlanEntry(
      entryId: 1,
      recipeId: 1,
      entryDate: DateTime(2026, 9, 28),
      mealSlot: MealSlot.lunch,
      mealTime: const TimeOfDay(hour: 12, minute: 30),
      title: title,
      note: 'Meal prepped',
      source: source,
      recipe: const Recipe(recipeId: 1, title: 'Penne Alla Vodka'),
    );

Future<void> _pump(WidgetTester tester, MealPlanEntry entry,
    {VoidCallback? onTap, VoidCallback? onEdit}) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: MealPlanEntryCard(entry: entry, onTap: onTap ?? () {}, onEdit: onEdit),
    ),
  ));
}

void main() {
  testWidgets('shows slot, recipe title, time and note', (tester) async {
    await _pump(tester, _entry());
    expect(find.text('LUNCH'), findsOneWidget);
    expect(find.text('Penne Alla Vodka'), findsOneWidget);
    expect(find.textContaining('12:30'), findsOneWidget);
    expect(find.textContaining('Meal prepped'), findsOneWidget);
  });

  testWidgets('title override  replaces the recipe name', (tester) async {
    await _pump(tester, _entry(title: 'Fish Night'));
    expect(find.text('Fish Night'), findsOneWidget);
    expect(find.text('Penne Alla Vodka'), findsNothing);
  });

  testWidgets('sparkle  only shows on recommended entres', (tester) async {
    await _pump(tester, _entry());
    expect(find.byIcon(Icons.auto_awesome), findsNothing);

    await _pump(tester, _entry(source: MealEntrySource.recommended));
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

  testWidgets('pencil is hidden without onEdit and fire  when given', (tester) async {
    await _pump(tester, _entry());
    expect(find.byIcon(Icons.edit_outlined), findsNothing);

    var edited = false;
    await _pump(tester, _entry(), onEdit: () => edited = true);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(edited, isTrue);
  });

  testWidgets('tapping the card calls onTap', (tester) async {
    var tapped = false;
    await _pump(tester, _entry(), onTap: () => tapped = true);

    await tester.tap(find.text('Penne Alla Vodka'));
    expect(tapped, isTrue);
  });

    testWidgets('shows the slot icon and Other for snacks', (tester) async {
    await _pump(tester, _entry());
    expect(find.byIcon(Icons.lunch_dining_outlined), findsOneWidget);

    await _pump(
      tester,
      MealPlanEntry(
        entryId: 2,
        recipeId: 1,
        entryDate: DateTime(2026, 9, 28),
        mealSlot: MealSlot.snack,
        mealTime: const TimeOfDay(hour: 15, minute: 0),
        recipe: const Recipe(recipeId: 1, title: 'Penne Alla Vodka'),
      ),
    );
    expect(find.text('OTHER'), findsOneWidget);
    expect(find.byIcon(Icons.cookie_outlined), findsOneWidget);
  });

  testWidgets('without a note only the time shows', (tester) async {
    await _pump(
      tester,
      MealPlanEntry(
        entryId: 3,
        recipeId: 1,
        entryDate: DateTime(2026, 9, 28),
        mealSlot: MealSlot.dinner,
        mealTime: const TimeOfDay(hour: 18, minute: 30),
        recipe: const Recipe(recipeId: 1, title: 'Penne Alla Vodka'),
      ),
    );
    expect(find.text('18:30'), findsOneWidget);
    expect(find.textContaining('·'), findsNothing);
  });
}