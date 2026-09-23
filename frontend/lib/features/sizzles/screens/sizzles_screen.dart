import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';
import '../../recipe/models/recipe.dart';
import '../../recipe/widgets/save_to_vault_sheet.dart';
import '../providers/sizzles_provider.dart';
import '../widgets/sizzle_video_player.dart';

typedef SizzleVideoBuilder = Widget Function(
  String videoUrl,
  bool active,
  bool muted,
);

class SizzlesScreen extends ConsumerStatefulWidget {
  const SizzlesScreen({super.key, this.videoBuilder});

  final SizzleVideoBuilder? videoBuilder;

  @override
  ConsumerState<SizzlesScreen> createState() => _SizzlesScreenState();
}

class _SizzlesScreenState extends ConsumerState<SizzlesScreen> {
  bool _muted = true;

  @override
  Widget build(BuildContext context) {
    final sizzles = ref.watch(sizzlesProvider);
    final notifier = ref.read(sizzlesProvider.notifier);

    return sizzles.when(
      loading: () => const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _SizzlesMessage(
        icon: Icons.wifi_off_outlined,
        message: error.toString(),
        actionLabel: 'Try Again',
        onAction: notifier.reset,
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return _SizzlesMessage(
            icon: Icons.ondemand_video_outlined,
            message: 'No Sizzles are available yet.',
            actionLabel: 'Refresh',
            onAction: notifier.reset,
          );
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: state.items.length,
          onPageChanged: notifier.onPageChanged,
          itemBuilder: (context, index) {
            final recipe = state.items[index];
            return _SizzlePage(
              key: ValueKey(recipe.recipeId),
              recipe: recipe,
              active: index == state.currentIndex,
              muted: _muted,
              videoBuilder: widget.videoBuilder,
              onMute: () => setState(() => _muted = !_muted),
              onSave: () {
                showSaveToVaultSheet(
                  context: context,
                  ref: ref,
                  recipeId: recipe.recipeId,
                );
              },
              onViewRecipe: () => context.push('/recipe/${recipe.recipeId}'),
            );
          },
        );
      },
    );
  }
}

class _SizzlePage extends StatelessWidget {
  const _SizzlePage({
    super.key,
    required this.recipe,
    required this.active,
    required this.muted,
    required this.onMute,
    required this.onSave,
    required this.onViewRecipe,
    this.videoBuilder,
  });

  final Recipe recipe;
  final bool active;
  final bool muted;
  final VoidCallback onMute;
  final VoidCallback onSave;
  final VoidCallback onViewRecipe;
  final SizzleVideoBuilder? videoBuilder;

  @override
  Widget build(BuildContext context) {
    final videoUrl = recipe.videoUrl!;
    final buildVideo = videoBuilder ?? _buildVideo;

    return Stack(
      fit: StackFit.expand,
      children: [
        buildVideo(videoUrl, active, muted),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xD9000000)],
              stops: [0.42, 1],
            ),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 24,
          child: Column(
            children: [
              _SizzleAction(
                icon: Icons.bookmark_border,
                label: 'Save',
                onTap: onSave,
              ),
              const SizedBox(height: 12),
              _SizzleAction(
                icon: muted ? Icons.volume_off : Icons.volume_up,
                label: muted ? 'Unmute' : 'Mute',
                onTap: onMute,
              ),
              const SizedBox(height: 12),
              _SizzleAction(
                icon: Icons.menu_book_outlined,
                label: 'Recipe',
                onTap: onViewRecipe,
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 88,
          bottom: 26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                recipe.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
              if (recipe.cuisineType != null &&
                  recipe.cuisineType!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _titleCase(recipe.cuisineType!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildVideo(String videoUrl, bool active, bool muted) {
  return SizzleVideoPlayer(
    videoUrl: videoUrl,
    active: active,
    muted: muted,
  );
}

class _SizzleAction extends StatelessWidget {
  const _SizzleAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      child: Column(
        children: [
          IconButton.filled(
            tooltip: label,
            onPressed: onTap,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
            ),
            icon: Icon(icon),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SizzlesMessage extends StatelessWidget {
  const _SizzlesMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 44),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _titleCase(String enumValue) {
  return enumValue
      .split('_')
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');
}
