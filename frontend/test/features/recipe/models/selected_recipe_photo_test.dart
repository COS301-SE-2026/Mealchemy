import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/selected_recipe_photo.dart';

//tests photo type and file size validation
void main() {
  group('SelectedRecipePhoto', () {
    test('accepts a supported content type', () {
      final photo = SelectedRecipePhoto.validate(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'dinner.jpg',
        contentType: 'image/jpeg',
      );

      expect(photo.contentType, 'image/jpeg');
      expect(photo.fileSizeBytes, 3);
    });

    test('infers content type from the file extension', () {
      final photo = SelectedRecipePhoto.validate(
        bytes: Uint8List.fromList([1]),
        fileName: 'dinner.webp',
      );

      expect(photo.contentType, 'image/webp');
    });

    test('rejects unsupported content types', () {
      expect(
        () => SelectedRecipePhoto.validate(
          bytes: Uint8List.fromList([1]),
          fileName: 'dinner.heic',
          contentType: 'image/heic',
        ),
        throwsA(isA<RecipePhotoValidationException>()),
      );
    });

    test('rejects files larger than 5 MB', () {
      expect(
        () => SelectedRecipePhoto.validate(
          bytes: Uint8List(
            SelectedRecipePhoto.maxFileSizeBytes + 1,
          ),
          fileName: 'dinner.png',
          contentType: 'image/png',
        ),
        throwsA(isA<RecipePhotoValidationException>()),
      );
    });
  });
}
