import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealchemy/features/recipe/services/recipe_video_picker.dart';

void main() {
  test('returns null when video selection is cancelled', () async {
    final picker = ImagePickerRecipeVideoPicker(
      pickVideo: (_) async => null,
    );

    expect(await picker.pickVideo(RecipeVideoSource.gallery), isNull);
  });

  test('returns a validated video from the selected source', () async {
    ImageSource? selectedSource;
    final picker = ImagePickerRecipeVideoPicker(
      pickVideo: (source) async {
        selectedSource = source;
        return XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          path: 'recipe.mp4',
          name: 'recipe.mp4',
          mimeType: 'video/mp4',
        );
      },
    );

    final video = await picker.pickVideo(RecipeVideoSource.camera);

    expect(selectedSource, ImageSource.camera);
    expect(video, isNotNull);
    expect(video!.contentType, 'video/mp4');
    expect(video.fileSizeBytes, 3);
  });
}
