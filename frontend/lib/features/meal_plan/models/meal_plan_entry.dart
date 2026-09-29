import 'package:flutter/material.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

class MealPlanEntry {
  final int? entryId;
  final int? planId;
  final int recipeId;
  final DateTime entryDate;
  final MealSlot mealSlot;
  final TimeOfDay mealTime;
  final String? title;
  final String? note;
  final MealEntrySource source;
  final int? addedBy;
  final Recipe? recipe;

  const MealPlanEntry({
    this.entryId,
    this.planId,
    required this.recipeId,
    required this.entryDate,
    required this.mealSlot,
    required this.mealTime,
    this.title,
    this.note,
    this.source = MealEntrySource.manual,
    this.addedBy,
    this.recipe,
  });

  String get displayTitle => title ?? recipe?.title ?? '';

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) {
    return MealPlanEntry(
      entryId: json['entryId'] as int?,
      planId: json['planId'] as int?,
      recipeId: json['recipeId'] as int,
      entryDate: DateTime.parse(json['entryDate'] as String),
      mealSlot: MealSlot.fromValue(json['mealSlot'] as String),
      mealTime: _parseTime(json['mealTime'] as String),
      title: json['title'] as String?,
      note: json['note'] as String?,
      source: MealEntrySource.fromValue(json['source'] as String? ?? 'MANUAL'),
      addedBy: json['addedBy'] as int?,
      recipe: json['recipe'] == null
          ? null
          : Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toRequestJson() => {
        'recipeId': recipeId,
        'entryDate': formatDate(entryDate),
        'mealSlot': mealSlot.value,
        'mealTime': formatTime(mealTime),
        'title': title,
        'note': note,
      };

  MealPlanEntry copyWith({
    int? recipeId,
    DateTime? entryDate,
    MealSlot? mealSlot,
    TimeOfDay? mealTime,
    String? title,
    String? note,
    Recipe? recipe,
  }) {
    return MealPlanEntry(
      entryId: entryId,
      planId: planId,
      recipeId: recipeId ?? this.recipeId,
      entryDate: entryDate ?? this.entryDate,
      mealSlot: mealSlot ?? this.mealSlot,
      mealTime: mealTime ?? this.mealTime,
      title: title ?? this.title,
      note: note ?? this.note,
      source: source,
      addedBy: addedBy,
      recipe: recipe ?? this.recipe,
    );
  }

  static TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String formatDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String formatTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

  static String _two(int n) => n.toString().padLeft(2, '0');
}
