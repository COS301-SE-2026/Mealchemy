import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/offline/providers/offline_cache_provider.dart';
import 'package:mealchemy/features/offline/repositories/cached_meal_plan_repository.dart';
import '../models/meal_plan.dart';
import '../models/meal_plan_entry.dart';
import '../models/meal_slot.dart';
import '../repositories/meal_plan_repository.dart';
import '../repositories/api_meal_plan_repository.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  final remote = ApiMealPlanRepository(ref.read(dioProvider));
  final viewerUserId = ref.watch(activeIdentityProvider);
  if (viewerUserId == null) return remote;
  return CachedMealPlanRepository(
    remote: remote,
    cache: ref.watch(mealPlanCacheStoreProvider),
    viewerUserId: viewerUserId,
  );
});

class MealPlanState {
  final bool isLoading;
  final String? errorMessage;
  final MealPlan? plan;
  final List<MealPlanEntry> entries;
  final DateTime selectedDay;
  final DateTime? windowStart;

  const MealPlanState({
    this.isLoading = false,
    this.errorMessage,
    this.plan,
    this.entries = const [],
    required this.selectedDay,
    this.windowStart,
  });

  List<MealPlanEntry> get dayEntries {
    final day =
        entries.where((e) => _sameDay(e.entryDate, selectedDay)).toList();
    int minutes(MealPlanEntry e) => e.mealTime.hour * 60 + e.mealTime.minute;
    day.sort((a, b) => minutes(a).compareTo(minutes(b)));
    return day;
  }

  MealSlot get firstFreeSlot {
    final taken = dayEntries.map((e) => e.mealSlot).toSet();
    return [MealSlot.breakfast, MealSlot.lunch, MealSlot.dinner]
            .where((s) => !taken.contains(s))
            .firstOrNull ??
        MealSlot.snack;
  }

  bool get hasLoaded => windowStart != null;

  MealPlanState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    MealPlan? plan,
    List<MealPlanEntry>? entries,
    DateTime? selectedDay,
    DateTime? windowStart,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      plan: plan ?? this.plan,
      entries: entries ?? this.entries,
      selectedDay: selectedDay ?? this.selectedDay,
      windowStart: windowStart ?? this.windowStart,
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _weekStart(DateTime d) =>
    _dateOnly(d).subtract(Duration(days: d.weekday - 1));

class MealPlanNotifier extends StateNotifier<MealPlanState> {
  final MealPlanRepository _repository;
  final int vaultId;

  MealPlanNotifier(this._repository, this.vaultId)
      : super(MealPlanState(selectedDay: _dateOnly(DateTime.now()))) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final plan = state.plan ?? await _repository.getOrCreatePlan(vaultId);
      final start = _weekStart(state.selectedDay);
      final entries = await _repository.getEntries(
        vaultId,
        start,
        start.add(const Duration(days: 6)),
      );
      state = state.copyWith(
        isLoading: false,
        plan: plan,
        entries: entries,
        windowStart: start,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _message(e));
    }
  }

  void selectDay(DateTime day) {
    final d = _dateOnly(day);
    state = state.copyWith(selectedDay: d);
    if (!_inWindow(d)) load();
  }

  void nextDay() => selectDay(state.selectedDay.add(const Duration(days: 1)));
  void previousDay() =>
      selectDay(state.selectedDay.subtract(const Duration(days: 1)));
  void goToToday() => selectDay(DateTime.now());

  Future<List<MealPlanEntry>> entriesBetween(DateTime start, DateTime end) =>
      _repository.getEntries(vaultId, start, end);

  Future<String?> addEntry(MealPlanEntry entry) => _add(entry);

  Future<String?> acceptRecommendation(
          MealPlanEntry entry, MealSuggestion suggestion) =>
      _add(entry, suggestion: suggestion);

  Future<String?> _add(MealPlanEntry entry,
      {MealSuggestion? suggestion}) async {
    final plan = state.plan;
    if (plan == null) return 'Meal plan not loaded yet';
    try {
      final saved = suggestion != null
          ? await _repository.acceptRecommendation(
              plan.planId, entry, suggestion)
          : await _repository.addEntry(plan.planId, entry);
      if (_inWindow(saved.entryDate)) {
        state = state.copyWith(entries: [...state.entries, saved]);
      }
      return null;
    } catch (e) {
      return _message(e);
    }
  }

  Future<String?> updateEntry(MealPlanEntry entry) async {
    final plan = state.plan;
    if (plan == null) return 'Meal plan not loaded yet';
    try {
      final saved = await _repository.updateEntry(plan.planId, entry);
      final rest = state.entries.where((e) => e.entryId != saved.entryId);
      state = state.copyWith(
        entries: [...rest, if (_inWindow(saved.entryDate)) saved],
      );
      return null;
    } catch (e) {
      return _message(e);
    }
  }

  Future<String?> deleteEntry(int entryId) async {
    final plan = state.plan;
    if (plan == null) return 'Meal plan not loaded yet';
    try {
      await _repository.deleteEntry(plan.planId, entryId);
      state = state.copyWith(
        entries: state.entries.where((e) => e.entryId != entryId).toList(),
      );
      return null;
    } catch (e) {
      return _message(e);
    }
  }

  Future<String?> clearDay() async {
    for (final e in state.dayEntries) {
      final error = await deleteEntry(e.entryId!);
      if (error != null) return error;
    }
    return null;
  }

  bool _inWindow(DateTime d) {
    final start = state.windowStart;
    if (start == null) return false;
    final day = _dateOnly(d);
    return !day.isBefore(start) &&
        day.isBefore(start.add(const Duration(days: 7)));
  }

  String _message(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) return data['message'];
      if (e.response?.statusCode == 409) return 'That slot already has a meal';
      if (e.response?.statusCode == 403) return "You can't edit this meal plan";
      return 'Could not reach the server';
    }
    if (e is ArgumentError) return e.message.toString();
    if (e is StateError) return e.message;
    return 'Something went wrong';
  }
}

final mealPlanProvider =
    StateNotifierProvider.family<MealPlanNotifier, MealPlanState, int>(
        (ref, vaultId) {
  return MealPlanNotifier(ref.watch(mealPlanRepositoryProvider), vaultId);
});

final mealSuggestionsProvider = FutureProvider.autoDispose.family<
    List<MealSuggestion>,
    ({int vaultId, DateTime date, MealSlot slot})>((ref, key) async {
  final plan = ref.watch(mealPlanProvider(key.vaultId).select((s) => s.plan));
  if (plan == null) return const [];
  return ref
      .watch(mealPlanRepositoryProvider)
      .previewRecommendations(plan.planId, key.date, key.slot);
});