class UnitOfMeasurement {
  final int unitId;
  final String name;
  final String? system;

  const UnitOfMeasurement({
    required this.unitId,
    required this.name,
    this.system,
  });

  factory UnitOfMeasurement.fromJson(Map<String, dynamic> json) {
    return UnitOfMeasurement(
      unitId: json['unit_id'] as int,
      name: json['name'] as String,
      system: json['system'] as String?,
    );
  }
}
