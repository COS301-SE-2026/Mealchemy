import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_welcome_bar.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan_entry.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';
import 'package:mealchemy/features/profile/repositories/profile_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';

class _FailingProfileRepository implements ProfileRepository {
  @override
  noSuchMethod(Invocation invocation) =>
      Future<Never>.error(Exception('no profile'));
}

MealPlanEntry _entry(MealSlot slot, int hour, int minute, String title) =>
    MealPlanEntry(
      recipeId: 1,
      entryDate: DateTime(2026, 9, 29),
      mealSlot: slot,
      mealTime: TimeOfDay(hour: hour, minute: minute),
      recipe: Recipe(recipeId: 1, title: title),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host() => ProviderScope(
        overrides: [
          profileRepositoryProvider
              .overrideWithValue(_FailingProfileRepository()),
          //no private vault means no meal plan to load
          vaultsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DashboardWelcomeBar()),
        ),
      );

  testWidgets('falls back to Chef when the profile is unavailable',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('NOTHING PLANNED YET'), findsOneWidget);
    expect(find.text('What are we cooking today?'), findsOneWidget);
  });

 group('welcomeMessage', () {
  final lunch = _entry(MealSlot.lunch, 12, 30, 'Caprese Pasta Salad');
  final dinner = _entry(MealSlot.dinner, 18, 30, 'Penne Alla Vodka');

  test('nothing planned asks what we are cooking', () {
    final m = welcomeMessage([], DateTime(2026, 9, 29, 10));
    expect(m.lead, 'Nothing planned yet');
    expect(m.highlight, 'What are we cooking today?');
  });

  test('within three hours counts down to the meal', () {
    final m = welcomeMessage([lunch, dinner], DateTime(2026, 9, 29, 10, 15));
    expect(m.lead, 'Lunch in 2h 15m');
    expect(m.highlight, 'Caprese Pasta Salad');
  });

  test('further out shows the meal time', () {
    final m = welcomeMessage([dinner], DateTime(2026, 9, 29, 9));
    expect(m.lead, 'Dinner at 18:30');
  });

  test('at meal time says enjoy', () {
    final m = welcomeMessage([lunch, dinner], DateTime(2026, 9, 29, 12, 45));
    expect(m.lead, 'Enjoy your lunch');
    expect(m.highlight, 'Caprese Pasta Salad');
  });

  test('after the eating window moves to the next meal', () {
    final m = welcomeMessage([lunch, dinner], DateTime(2026, 9, 29, 14));
    expect(m.lead, 'Dinner at 18:30');
  });

  test('after the last meal says done for today', () {
    final m = welcomeMessage([lunch, dinner], DateTime(2026, 9, 29, 20));
    expect(m.lead, "You're done for today");
  });

  test('ignores meals on other days', () {
    final tomorrow = MealPlanEntry(
      recipeId: 1,
      entryDate: DateTime(2026, 9, 30),
      mealSlot: MealSlot.lunch,
      mealTime: const TimeOfDay(hour: 12, minute: 0),
    );
    final m = welcomeMessage([tomorrow], DateTime(2026, 9, 29, 10));
    expect(m.lead, 'Nothing planned yet');
  });
});
}