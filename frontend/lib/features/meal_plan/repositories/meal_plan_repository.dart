import '../models/meal_plan.dart';
import '../models/meal_plan_entry.dart';

abstract class MealPlanRepository {
  Future<MealPlan> getOrCreatePlan(int vaultId);
  Future<List<MealPlanEntry>> getEntries(int vaultId, DateTime start, DateTime end);
  Future<MealPlanEntry> addEntry(int planId, MealPlanEntry entry);
  Future<MealPlanEntry> updateEntry(int planId, MealPlanEntry entry);
  Future<void> deleteEntry(int planId, int entryId);
}