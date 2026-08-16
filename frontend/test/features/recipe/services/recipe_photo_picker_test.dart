import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealchemy/features/recipe/services/recipe_photo_picker.dart';

//tests photo selection without opening the platform picker
void main() {
  test('returns null when image selection is cancelled', () async {
    final picker = ImagePickerRecipePhotoPicker(
      pickImage: (_) async => null,
    );

    expect(await picker.pickPhoto(RecipePhotoSource.gallery), isNull);
  });

  test('returns validated bytes from the selected image', () async {
    ImageSource? selectedSource;
    final picker = ImagePickerRecipePhotoPicker(
      pickImage: (source) async {
        selectedSource = source;
        return XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'meal.png',
          mimeType: 'image/png',
        );
      },
    );

    final photo = await picker.pickPhoto(RecipePhotoSource.camera);

    expect(selectedSource, ImageSource.camera);
    expect(photo, isNotNull);
    expect(photo!.contentType, 'image/png');
    expect(photo.bytes, [1, 2, 3]);
  });
}
