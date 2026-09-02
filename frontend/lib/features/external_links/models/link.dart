class Link {
  const Link({
    required this.linkId,
    required this.name,
    required this.url,
    required this.createdAt,
    this.updatedAt,
  });
  final int linkId;
  final String name;
  final String url;
  final DateTime createdAt;
  final DateTime? updatedAt;

  //null until the link has been edited at least once
  bool get isEdited => updatedAt != null;
  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      linkId: json['link_id'] as int,
      name: json['name'] as String,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }
  //create and update send the same shap name and url
  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };

  Link copyWith({
    int? linkId,
    String? name,
    String? url,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Link(
      linkId: linkId ?? this.linkId,
      name: name ?? this.name,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}