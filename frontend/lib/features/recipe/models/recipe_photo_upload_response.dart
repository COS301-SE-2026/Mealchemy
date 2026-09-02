//signed upload details returned by the backend
class RecipePhotoUploadResponse {
  const RecipePhotoUploadResponse({
    required this.uploadUrl,
    required this.photoUrl,
    required this.requiredHeaders,
    required this.expiresAt,
  });

  final String uploadUrl;
  final String photoUrl;
  final Map<String, String> requiredHeaders;
  final DateTime expiresAt;

  factory RecipePhotoUploadResponse.fromJson(Map<String, dynamic> json) {
    final headers =
        json['requiredHeaders'] as Map<String, dynamic>? ?? const {};
    return RecipePhotoUploadResponse(
      uploadUrl: json['uploadUrl'] as String,
      photoUrl: json['photoUrl'] as String,
      requiredHeaders: headers.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

//mirrors response form POST/recipes/{id}/photo-upload-url
