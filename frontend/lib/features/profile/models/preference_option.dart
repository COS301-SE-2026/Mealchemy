//One selectable option from a backend catalog gets
class PreferenceOption {
  const PreferenceOption({
    required this.value,
    required this.label,
    this.id,
  });

  final String value;
  final String label;

  final int? id;

  factory PreferenceOption.fromJson(Map<String, dynamic> json) {
    return PreferenceOption(
      id: json['id'] as int?,
      value: json['value'] as String,
      label: json['label'] as String? ?? json['value'] as String,
    );
  }
}