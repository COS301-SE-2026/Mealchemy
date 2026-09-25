class Equipment {
  const Equipment({
    required this.id,
    required this.value,
    required this.label,
  });

  final int id;
  final String value;
  final String label;

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['equipmentId'] as int,
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }
}