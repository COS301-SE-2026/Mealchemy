import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe_photo_upload_response.dart';

//tests parsing the signed upload response
void main() {
  test('parses the signed upload response', () {
    final response = RecipePhotoUploadResponse.fromJson({
      'uploadUrl': 'https://storage.googleapis.com/upload',
      'photoUrl': 'https://storage.googleapis.com/photo.jpg',
      'requiredHeaders': {
        'Content-Type': 'image/jpeg',
        'Content-Length': '3',
      },
      'expiresAt': '2026-08-16T12:00:00Z',
    });

    expect(response.uploadUrl, 'https://storage.googleapis.com/upload');
    expect(response.photoUrl, 'https://storage.googleapis.com/photo.jpg');
    expect(response.requiredHeaders['Content-Type'], 'image/jpeg');
    expect(response.expiresAt, DateTime.utc(2026, 8, 16, 12));
  });
}
