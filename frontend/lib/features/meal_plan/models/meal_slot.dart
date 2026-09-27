import 'package:flutter/material.dart';

enum MealSlot {
  breakfast('BREAKFAST', 'Breakfast', Icons.free_breakfast_outlined,
      TimeOfDay(hour: 5, minute: 0), TimeOfDay(hour: 11, minute: 0)),
  lunch('LUNCH', 'Lunch', Icons.lunch_dining_outlined,
      TimeOfDay(hour: 11, minute: 0), TimeOfDay(hour: 16, minute: 0)),
  dinner('DINNER', 'Dinner', Icons.dinner_dining_outlined,
      TimeOfDay(hour: 16, minute: 0), TimeOfDay(hour: 23, minute: 0)),
  snack('SNACK', 'Snack', Icons.cookie_outlined, null, null);

  final String value;
  final String label;
  final IconData icon;
  final TimeOfDay? earliest;
  final TimeOfDay? latest;

  const MealSlot(this.value, this.label, this.icon, this.earliest, this.latest);

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
