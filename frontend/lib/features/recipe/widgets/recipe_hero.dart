import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe.dart';

//image with overlay, back/share buttons, recipe title
class RecipeHero extends StatelessWidget {
  const RecipeHero({super.key, required this.recipe, this.height = 290});

  final Recipe recipe;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroImage(photoUrl: recipe.photoUrl),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppColors.brandOverlay),
            ),
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.bgDark.withValues(alpha: 0.8)],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _HeroCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                    background: AppColors.surfaceWhite.withValues(alpha: 0.95),
                    iconColor: AppColors.textLight,
                    frosted: false,
                  ),
                  const Spacer(),
                  _HeroCircleButton(
                    icon: Icons.favorite_border,
                    onTap: () {},
                    background: AppColors.textLight.withValues(alpha: 0.45),
                    iconColor: AppColors.textDark,
                    frosted: true,
                  ),
                  const SizedBox(width: 10),
                  _HeroCircleButton(
                    icon: Icons.share_outlined,
                    onTap: () {},
                    background: AppColors.textLight.withValues(alpha: 0.45),
                    iconColor: AppColors.textDark,
                    frosted: true,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Text(
              recipe.title,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.textDark,
                fontSize: 30,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _HeroPlaceholder(),
      );
    }
    return const _HeroPlaceholder();
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandOverlay),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          color: AppColors.accent,
          size: 72,
        ),
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.iconColor,
    this.frosted = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
      ),
      child: Icon(icon, color: iconColor, size: 19),
    );

    return GestureDetector(
      onTap: onTap,
      child: frosted
          ? ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: button,
              ),
            )
          : button,
    );
  }
}
