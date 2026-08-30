//returned when external ingredient needs category before import
class PendingExternalIngredient {
  const PendingExternalIngredient({
    required this.sourceId,
    required this.name,
  });

  final String sourceId;
  final String name;

  factory PendingExternalIngredient.fromJson(Map<String, dynamic> json) {
    final sourceId = json['source_id']?.toString();

    if (sourceId == null || sourceId.isEmpty) {
      throw const FormatException(
        'Pending external ingredient requires source_id.',
      );
    }

    return PendingExternalIngredient(
      sourceId: sourceId,
      name: json['name']?.toString() ?? '',
    );
  }
}
