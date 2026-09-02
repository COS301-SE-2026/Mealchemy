import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/profile/models/preference_option.dart';

void main() {
  group('PreferenceOption.fromJson', () {
    test('parses a full payload with id , value and label', () {
      final option = PreferenceOption.fromJson(<String, dynamic>{
        'id': 3,
        'value': 'GLUTEN_FREE',
        'label': 'Gluten-Free',
      });
      expect(option.id, 3);
      expect(option.value, 'GLUTEN_FREE');
      expect(option.label, 'Gluten-Free');
    });

    test('parses a payload without an id  flavour profile shape', () {
      final option = PreferenceOption.fromJson(<String, dynamic>{
        'value': 'italian',
        'label': 'Italian',
      });

      expect(option.id, isNull);
      expect(option.value, 'italian');
      expect(option.label, 'Italian');
    });

    test('falls back to value when label is missing', () {
      final option = PreferenceOption.fromJson(<String, dynamic>{
        'value': 'HIGH_PROTEIN',
      });
      expect(option.value, 'HIGH_PROTEIN');
      expect(option.label, 'HIGH_PROTEIN');
    });
  });
}