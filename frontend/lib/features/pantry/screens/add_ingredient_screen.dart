import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

const double _blurArea = 240;
const double _sheetTop = 212;

class AddIngredientScreen extends StatelessWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _blurArea,
            child: _PantryHeader(),
          ),
          //rounded sheet pulled up over the hero
          Positioned.fill(
            top: _sheetTop,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bgCream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 14),
                
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _SheetHandle(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//blurred translucent header 
class _PantryHeader extends StatelessWidget {
  const _PantryHeader();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _blurArea,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [

          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const DecoratedBox(
                decoration: BoxDecoration(color: AppColors.overlayLight),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                    background: AppColors.textMuted.withValues(alpha: 0.45),
                    iconColor: AppColors.textDark,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _HeaderCircleButton(
                        icon: Icons.add,
                        onTap: () {},
                        background: AppColors.textMuted.withValues(alpha: 0.25),
                        iconColor: AppColors.primary,

                      ),
                      const SizedBox(height: 10),
                      _HeaderCircleButton(
                        icon: Icons.photo_camera_outlined,
                        onTap: () {},
                        background: AppColors.textMuted.withValues(alpha: 0.25),
                        iconColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background,
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
    );
  }
}

//small pill at the top of the sheet
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.tertiaryMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
