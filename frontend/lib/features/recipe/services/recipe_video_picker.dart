import 'package:image_picker/image_picker.dart';

import '../models/selected_recipe_video.dart';

enum RecipeVideoSource { gallery, camera }

abstract class RecipeVideoPicker {
  Future<SelectedRecipeVideo?> pickVideo(RecipeVideoSource source);
}

typedef PickVideoCallback = Future<XFile?> Function(ImageSource source);

class ImagePickerRecipeVideoPicker implements RecipeVideoPicker {
  ImagePickerRecipeVideoPicker({
    ImagePicker? imagePicker,
    PickVideoCallback? pickVideo,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _pickVideo = pickVideo;

  final ImagePicker _imagePicker;
  final PickVideoCallback? _pickVideo;

  @override
  Future<SelectedRecipeVideo?> pickVideo(RecipeVideoSource source) async {
    final imageSource = source == RecipeVideoSource.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    final pickVideo = _pickVideo;
    final file = pickVideo == null
        ? await _imagePicker.pickVideo(source: imageSource)
        : await pickVideo(imageSource);
    if (file == null) return null;
    return SelectedRecipeVideo.validate(file);
  }
}
