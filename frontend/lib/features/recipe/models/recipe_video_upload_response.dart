// Signed upload details returned by the backend.
class RecipeVideoUploadResponse {
  const RecipeVideoUploadResponse({
    required this.uploadUrl,
    required this.videoUrl,
    required this.requiredHeaders,
    required this.expiresAt,
  });

  final String uploadUrl;
  final String videoUrl;
  final Map<String, String> requiredHeaders;
  final DateTime expiresAt;

  factory RecipeVideoUploadResponse.fromJson(Map<String, dynamic> json) {
    final headers =
        json['requiredHeaders'] as Map<String, dynamic>? ?? const {};
    return RecipeVideoUploadResponse(
      uploadUrl: json['uploadUrl'] as String,
      videoUrl: json['videoUrl'] as String,
      requiredHeaders: headers.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
