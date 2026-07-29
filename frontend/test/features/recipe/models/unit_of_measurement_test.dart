import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/unit_of_measurement.dart';
 
void main() {
  group('UnitOfMeasurement.fromJson', () {
    test('parses a unit with a measurement system', () {
      final unit = UnitOfMeasurement.fromJson(const {
        'unit_id': 1,
        'name': 'g',
        'system': 'METRIC',
      });
 
      expect(unit.unitId, 1);
      expect(unit.name, 'g');
      expect(unit.system, 'METRIC');
    });
 
    test('parses a count-based unit with a null system', () {
      final unit = UnitOfMeasurement.fromJson(const {
        'unit_id': 5,
        'name': 'tbsp',
        'system': null,
      });
 
      expect(unit.name, 'tbsp');
      expect(unit.system, isNull);
    });
  });
}