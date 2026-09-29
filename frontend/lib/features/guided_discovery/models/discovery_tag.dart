class DiscoveryTag {
  const DiscoveryTag({
    required this.tagId,
    required this.tagName,
    required this.isDietary,
  });

  final int tagId;
  final String tagName;
  final bool isDietary;

  String get label => tagName
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  factory DiscoveryTag.fromJson(Map<String, dynamic> json) {
    return DiscoveryTag(
      tagId: json['tagId'] as int,
      tagName: json['tagName'] as String,
      isDietary: json['isDietary'] as bool? ?? false,
    );
  }
}