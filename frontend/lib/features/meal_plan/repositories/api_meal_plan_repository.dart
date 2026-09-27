import 'package:dio/dio.dart';
import 'meal_plan_repository.dart';
import '../models/meal_plan.dart';
import '../models/meal_plan_entry.dart';

class ApiMealPlanRepository implements MealPlanRepository {
  final Dio _dio;

  ApiMealPlanRepository(this._dio);
  @override
  Future<MealPlan> getOrCreatePlan(int vaultId) async {
    final res = await _dio.post('/api/meal-plans', data: {'vaultId': vaultId});
    return MealPlan.fromJson(res.data);
  }

  @override
  Future<List<MealPlanEntry>> getEntries(int vaultId, DateTime start, DateTime end) async {
    final res = await _dio.get('/api/meal-plans', queryParameters: {
      'vaultId': vaultId,
      'startDate': MealPlanEntry.formatDate(start),
      'endDate': MealPlanEntry.formatDate(end),
    });
    
    final data = res.data;
    final list = data is List ? data : (data['entries'] as List? ?? []);
    return list.map((j) => MealPlanEntry.fromJson(j)).toList();
  }

  @override
  Future<MealPlanEntry> addEntry(int planId, MealPlanEntry entry) async {
    final res = await _dio.post('/api/meal-plans/$planId/entries', data: entry.toRequestJson());
    return MealPlanEntry.fromJson(res.data);
  }
  @override
  Future<MealPlanEntry> updateEntry(int planId, MealPlanEntry entry) async {
    final res = await _dio.put(
      '/api/meal-plans/$planId/entries/${entry.entryId}',
      data: entry.toRequestJson(),
    );
    return MealPlanEntry.fromJson(res.data);
  }

  @override
  Future<void> deleteEntry(int planId, int entryId) async {
    await _dio.delete('/api/meal-plans/$planId/entries/$entryId');
  }
}