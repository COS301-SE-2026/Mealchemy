import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/selected_recipe_video.dart';

class RecipeVideoSelector extends StatelessWidget {
  const RecipeVideoSelector({
    super.key,
    required this.video,
    required this.existingVideoUrl,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onRemoveTap,
    required this.disabled,
    required this.uploading,
  });

  final SelectedRecipeVideo? video;
  final String? existingVideoUrl;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onRemoveTap;
  final bool disabled;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    final hasVideo = video != null || existingVideoUrl != null;
    final actionsDisabled = disabled || uploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const Key('recipe-video-summary'),
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                hasVideo
                    ? Icons.video_file_outlined
                    : Icons.video_call_outlined,
                size: 36,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      video?.fileName ??
                          (existingVideoUrl != null
                              ? 'Video attached'
                              : 'No video selected'),
                      key: const Key('recipe-video-label'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (video != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(video!.fileSizeBytes),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (uploading)
                const SizedBox(
                  key: Key('recipe-video-uploading'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (hasVideo)
                IconButton(
                  key: const Key('recipe-video-remove'),
                  onPressed: actionsDisabled ? null : onRemoveTap,
                  tooltip: 'Remove video',
                  color: AppColors.error,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('recipe-video-gallery'),
                onPressed: actionsDisabled ? null : onGalleryTap,
                icon: const Icon(Icons.video_library_outlined),
                label: Text(hasVideo ? 'Replace' : 'Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('recipe-video-camera'),
                onPressed: actionsDisabled ? null : onCameraTap,
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    final megabytes = bytes / (1024 * 1024);
    return '${megabytes.toStringAsFixed(megabytes < 10 ? 1 : 0)} MB';
  }
}
