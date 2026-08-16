import 'package:image_picker/image_picker.dart';

import '../models/selected_recipe_photo.dart';

//selects and validates a photo from the gallery or camera
enum RecipePhotoSource { gallery, camera }

abstract class RecipePhotoPicker {
  Future<SelectedRecipePhoto?> pickPhoto(RecipePhotoSource source);

  Future<SelectedRecipePhoto?> recoverLostPhoto();
}

typedef PickImageCallback = Future<XFile?> Function(ImageSource source);

class ImagePickerRecipePhotoPicker implements RecipePhotoPicker {
  ImagePickerRecipePhotoPicker({
    ImagePicker? imagePicker,
    PickImageCallback? pickImage,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _pickImage = pickImage;

  final ImagePicker _imagePicker;
  final PickImageCallback? _pickImage;

  @override
  Future<SelectedRecipePhoto?> pickPhoto(RecipePhotoSource source) async {
    final imageSource = source == RecipePhotoSource.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    final pickImage = _pickImage;
    final file = pickImage == null
        ? await _imagePicker.pickImage(
            source: imageSource,
            imageQuality: 85,
            maxWidth: 2048,
            requestFullMetadata: false,
          )
        : await pickImage(imageSource);
    return _toSelectedPhoto(file);
  }

  @override
  Future<SelectedRecipePhoto?> recoverLostPhoto() async {
    final response = await _imagePicker.retrieveLostData();
    if (response.isEmpty) return null;
    if (response.exception != null) {
      throw RecipePhotoValidationException(
        response.exception!.message ?? 'Could not recover the selected photo.',
      );
    }
    final files = response.files;
    return _toSelectedPhoto(
        files == null || files.isEmpty ? null : files.first);
  }

  Future<SelectedRecipePhoto?> _toSelectedPhoto(XFile? file) async {
    if (file == null) return null;
    return SelectedRecipePhoto.validate(
      bytes: await file.readAsBytes(),
      fileName: file.name,
      contentType: file.mimeType,
    );
  }
}
