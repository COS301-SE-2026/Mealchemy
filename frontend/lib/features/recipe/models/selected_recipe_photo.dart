import 'dart:typed_data';


//represents a photo after selection but before it gets uploaded
//uses client-side validation
//stores raw image bytes, orignal filename, validated content type, calculated file size
class SelectedRecipePhoto {
  const SelectedRecipePhoto._({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const Set<String> supportedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  final Uint8List bytes;
  final String fileName;
  final String contentType;

  int get fileSizeBytes => bytes.lengthInBytes;

  factory SelectedRecipePhoto.validate({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) {
    if (bytes.isEmpty) {
      throw const RecipePhotoValidationException(
          'The selected photo is empty.');
    }

    if (bytes.lengthInBytes > maxFileSizeBytes) {
      throw const RecipePhotoValidationException(
        'Choose a photo smaller than 5 MB.',
      );
    }

    final resolvedContentType = _resolveContentType(fileName, contentType);
    if (resolvedContentType == null ||
        !supportedContentTypes.contains(resolvedContentType)) {
      throw const RecipePhotoValidationException(
        'Choose a JPEG, PNG, or WebP photo.',
      );
    }

    return SelectedRecipePhoto._(
      bytes: bytes,
      fileName: fileName,
      contentType: resolvedContentType,
    );
  }

  static String? _resolveContentType(String fileName, String? contentType) {
    final normalized = contentType?.split(';').first.trim().toLowerCase();
    if (normalized != null &&
        normalized.isNotEmpty &&
        normalized != 'application/octet-stream') {
      return normalized == 'image/jpg' ? 'image/jpeg' : normalized;
    }

    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => null,
    };
  }
}

class RecipePhotoValidationException implements Exception {
  const RecipePhotoValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
