import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../models/selected_recipe_photo.dart';
import 'recipe_network_image.dart';

//photo controls used inside the add recipe form
class RecipePhotoSelector extends StatelessWidget {
  const RecipePhotoSelector({
    super.key,
    required this.photo,
    this.existingPhotoUrl,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onRemoveTap,
    this.disabled = false,
    this.uploading = false,
  });

  final SelectedRecipePhoto? photo;
  final String? existingPhotoUrl;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onRemoveTap;
  final bool disabled;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo != null || existingPhotoUrl != null;
    final actionsDisabled = disabled || uploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!hasPhoto)
                  const _PhotoPlaceholder()
                else if (photo != null)
                  Image.memory(
                    photo!.bytes,
                    key: const Key('recipe-photo-preview'),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
                  )
                else
                  RecipeNetworkImage(
                    key: const Key('recipe-photo-preview'),
                    photoUrl: existingPhotoUrl,
                    placeholder: const _PhotoPlaceholder(),
                    fit: BoxFit.cover,
                  ),
                if (hasPhoto)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      key: const Key('recipe-photo-remove'),
                      onPressed: actionsDisabled ? null : onRemoveTap,
                      tooltip: 'Remove photo',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppColors.surfaceWhite.withValues(alpha: 0.95),
                        foregroundColor: AppColors.error,
                      ),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                if (uploading)
                  ColoredBox(
                    key: const Key('recipe-photo-uploading'),
                    color: AppColors.surfaceWhite.withValues(alpha: 0.75),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('recipe-photo-gallery'),
                onPressed: actionsDisabled ? null : onGalleryTap,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('recipe-photo-camera'),
                onPressed: actionsDisabled ? null : onCameraTap,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('recipe-photo-placeholder'),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 44,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
