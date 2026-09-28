import 'package:image_picker/image_picker.dart';

// Represents a validated video before it is uploaded.
class SelectedRecipeVideo {
  const SelectedRecipeVideo._({
    required this.file,
    required this.fileName,
    required this.contentType,
    required this.fileSizeBytes,
  });

  static const int maxFileSizeBytes = 50 * 1024 * 1024;
  static const String supportedContentType = 'video/mp4';

  final XFile file;
  final String fileName;
  final String contentType;
  final int fileSizeBytes;

  static Future<SelectedRecipeVideo> validate(XFile file) async {
    final fileSizeBytes = await file.length();
    if (fileSizeBytes == 0) {
      throw const RecipeVideoValidationException(
        'The selected video is empty.',
      );
    }
    if (fileSizeBytes > maxFileSizeBytes) {
      throw const RecipeVideoValidationException(
        'Choose an MP4 video smaller than 50 MB.',
      );
    }

    final contentType = _resolveContentType(file.name, file.mimeType);
    if (contentType == null || contentType != supportedContentType) {
      throw const RecipeVideoValidationException(
        'Choose an MP4 video.',
      );
    }

    return SelectedRecipeVideo._(
      file: file,
      fileName: file.name,
      contentType: contentType,
      fileSizeBytes: fileSizeBytes,
    );
  }

  static String? _resolveContentType(String fileName, String? contentType) {
    final normalized = contentType?.split(';').first.trim().toLowerCase();
    if (normalized != null &&
        normalized.isNotEmpty &&
        normalized != 'application/octet-stream') {
      return normalized;
    }
    return fileName.toLowerCase().endsWith('.mp4')
        ? supportedContentType
        : null;
  }
}

class RecipeVideoValidationException implements Exception {
  const RecipeVideoValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
