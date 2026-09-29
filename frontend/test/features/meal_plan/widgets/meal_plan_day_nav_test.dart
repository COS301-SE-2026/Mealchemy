import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/meal_plan/widgets/meal_plan_day_nav.dart';

void main() {
  test('formatDay uses weekday and ordinal', () {
    expect(MealPlanDayNav.formatDay(DateTime(2026, 9, 28)), 'Monday 28th');
    expect(MealPlanDayNav.formatDay(DateTime(2026, 10, 1)), 'Thursday 1st');
    expect(MealPlanDayNav.formatDay(DateTime(2026, 10, 2)), 'Friday 2nd');
    expect(MealPlanDayNav.formatDay(DateTime(2026, 10, 3)), 'Saturday 3rd');
    expect(MealPlanDayNav.formatDay(DateTime(2026, 10, 11)), 'Sunday 11th');
    expect(MealPlanDayNav.formatDay(DateTime(2026, 10, 22)), 'Thursday 22nd');
  });

  Future<void> pump(
    WidgetTester tester,
    DateTime day, {
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    VoidCallback? onToday,
  }) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MealPlanDayNav(
          day: day,
          onPrevious: onPrevious ?? () {},
          onNext: onNext ?? () {},
          onToday: onToday ?? () {},
          onDateSelected: (_) {},
        ),
      ),
    ));
  }

  testWidgets('chevrons call previous and next', (tester) async {
    var prev = 0;
    var next = 0;
    await pump(tester, DateTime.now(), onPrevious: () => prev++, onNext: () => next++);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.tap(find.byIcon(Icons.chevron_right));
    expect(prev, 1);
    expect(next, 1);
  });

  testWidgets('back to today only shows away from today', (tester) async {
    await pump(tester, DateTime.now());
    expect(find.text('BACK TO TODAY'), findsNothing);
    var today = false;
    await pump(tester, DateTime.now().add(const Duration(days: 3)), onToday: () => today = true);
    await tester.tap(find.text('BACK TO TODAY'));
    expect(today, isTrue);
  });
}