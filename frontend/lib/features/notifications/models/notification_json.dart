class NotificationJson {
  NotificationJson._();

  static Map<String, dynamic> object(Object? value) {
    if (value is! Map || value.keys.any((key) => key is! String)) {
      throw const FormatException('Expected a notification JSON object.');
    }
    return Map<String, dynamic>.from(value);
  }

  static int integer(
    Object? value,
    String field, {
    int minimum = 0,
  }) {
    if (value is! int || value < minimum) {
      throw FormatException('Invalid $field.');
    }
    return value;
  }

  static int? optionalId(Object? value, String field) {
    if (value == null) return null;
    return integer(value, field, minimum: 1);
  }

  static String text(Object? value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Invalid $field.');
    }
    return value;
  }

  static bool boolean(Object? value, String field) {
    if (value is! bool) {
      throw FormatException('Invalid $field.');
    }
    return value;
  }

  static DateTime timestamp(Object? value, String field) {
    final raw = text(value, field);

    //require explicit offset so device-local time cannot be mistaken for the server timestamp
    if (!RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(raw)) {
      throw FormatException('$field must include a timezone offset.');
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      throw FormatException('Invalid $field.');
    }

    return parsed.toUtc();
  }
}
