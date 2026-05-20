import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: 
        BorderRadius.circular(30),
      child: SizedBox(
        height: 400,
        width: double.infinity,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.brandOverlay, //used the overlay created in the app_colours
                ),
              ),
            ),

            // Content  centered
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  Text(
                    'Mealchemy',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.textDark,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ELEVATE YOUR BITE WITH MEALCHEMY',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textDark,
                      letterSpacing: 2,
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}