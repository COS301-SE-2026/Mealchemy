import 'package:flutter/material.dart';

enum MealSlot {
  breakfast('BREAKFAST', 'Breakfast', TimeOfDay(hour: 5, minute: 0),
      TimeOfDay(hour: 11, minute: 0)),
  lunch('LUNCH', 'Lunch', TimeOfDay(hour: 11, minute: 0),
      TimeOfDay(hour: 16, minute: 0)),
  dinner('DINNER', 'Dinner', TimeOfDay(hour: 16, minute: 0),
      TimeOfDay(hour: 23, minute: 0)),
  snack('SNACK', 'Snack', null, null);

  final String value;
  final String label;
  final TimeOfDay? earliest;
  final TimeOfDay? latest;

  const MealSlot(this.value, this.label, this.earliest, this.latest);

  static MealSlot fromValue(String v) => values.firstWhere((s) => s.value == v);

  bool allows(TimeOfDay t) {
    if (earliest == null || latest == null) return true;
    final m = t.hour * 60 + t.minute;
    return m >= earliest!.hour * 60 + earliest!.minute &&
        m <= latest!.hour * 60 + latest!.minute;
  }
}

enum MealEntrySource {
  manual('MANUAL'),
  recommended('RECOMMENDED');
  final String value;
  const MealEntrySource(this.value);
  static MealEntrySource fromValue(String v) =>
      values.firstWhere((s) => s.value == v);
}
