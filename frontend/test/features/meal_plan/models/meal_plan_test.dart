import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan.dart';

void main() {
  test('MealPlan.fromJson reads plan and vault ids', () {
    final plan = MealPlan.fromJson({'planId': 7, 'vaultId': 3});

    expect(plan.planId, 7);
    expect(plan.vaultId, 3);
  });
}