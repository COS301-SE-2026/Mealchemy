import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealchemy/features/recipe/models/selected_recipe_video.dart';

void main() {
  test('accepts a non-empty MP4 file', () async {
    final video = await SelectedRecipeVideo.validate(
      XFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        path: 'recipe.mp4',
        name: 'recipe.mp4',
        mimeType: 'video/mp4',
      ),
    );

    expect(video.fileName, 'recipe.mp4');
    expect(video.contentType, 'video/mp4');
    expect(video.fileSizeBytes, 3);
  });

  test('uses the MP4 extension when the picker has no useful MIME type',
      () async {
    final video = await SelectedRecipeVideo.validate(
      XFile.fromData(
        Uint8List.fromList([1]),
        path: 'recipe.MP4',
        name: 'recipe.MP4',
        mimeType: 'application/octet-stream',
      ),
    );

    expect(video.contentType, 'video/mp4');
  });

  test('rejects a non-MP4 file', () async {
    await expectLater(
      SelectedRecipeVideo.validate(
        XFile.fromData(
          Uint8List.fromList([1]),
          path: 'recipe.mov',
          name: 'recipe.mov',
          mimeType: 'video/quicktime',
        ),
      ),
      throwsA(isA<RecipeVideoValidationException>()),
    );
  });
}
