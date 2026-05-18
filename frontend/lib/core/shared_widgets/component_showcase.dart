// This is a temporary file for showcasing components during development please add and remove componets as needed.
//FILE WILL BE REMOVED before demo day
import 'package:flutter/material.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/theme/app_colours.dart';


class ComponentShowcase extends StatelessWidget {
  const ComponentShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Component Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            //Buttons
            Text('Primary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppButton.primary(label: 'Get Started', onPressed: () {}),
            const SizedBox(height: 8),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Fixed 200px',
                onPressed: () {},
                isFullWidth: true,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: AppButton.primary(
                label: '60% width',
                onPressed: () {},
                isFullWidth: true,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: AppButton.primary(
                label: 'Padded',
                onPressed: () {},
                isFullWidth: true,
              ),
            ),
            const SizedBox(height: 24),

            Text('Secondary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppButton.secondary(
              label: 'Browse Recipes',
              onPressed: () {},
              isFullWidth: true,
            ),
            const SizedBox(height: 24),

            Text('Outlined', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppButton.outlined(
              label: 'Default colour',
              onPressed: () {},
              isFullWidth: true,
            ),
            const SizedBox(height: 8),
            AppButton.outlined(
              label: 'Custom colour',
              onPressed: () {},
              isFullWidth: true,
              customColor: AppColors.tertiaryMuted,
            ),
            const SizedBox(height: 8),
            AppButton.outlined(
              label: 'Error colour',
              onPressed: () {},
              isFullWidth: true,
              customColor: AppColors.error,
            ),
            const SizedBox(height: 24),

            Text('Text', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppButton.text(
              label: 'Default ghost',
              onPressed: () {},
              isFullWidth: true,
            ),
            const SizedBox(height: 8),
            AppButton.text(
              label: 'Custom ghost',
              onPressed: () {},
              isFullWidth: true,
              customColor: AppColors.accent,
            ),
            const SizedBox(height: 24),

            Text('Sizes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppButton.primary(
              label: 'Small',
              onPressed: () {},
              size: ButtonSize.small,
            ),
            const SizedBox(height: 8),
            AppButton.primary(
              label: 'Medium',
              onPressed: () {},
              size: ButtonSize.medium,
            ),
            const SizedBox(height: 8),
            AppButton.primary(
              label: 'Large',
              onPressed: () {},
              size: ButtonSize.large,
              isFullWidth: true,
            ),
            const SizedBox(height: 24),

            Text('Rounded', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppButton.primary(
              label: 'Rounded Primary',
              onPressed: () {},
              isFullWidth: true,
              isRounded: true,
            ),
            const SizedBox(height: 8),
            AppButton.outlined(
              label: 'Rounded Outlined',
              onPressed: () {},
              isFullWidth: true,
              isRounded: true,
            ),
            const SizedBox(height: 24),

            Text('With Icons', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppButton.primary(
              label: 'Scan Pantry',
              onPressed: () {},
              leftIcon: Icons.camera_alt,
              isFullWidth: true,
            ),
            const SizedBox(height: 8),
            AppButton.outlined(
              label: 'Next Step',
              onPressed: () {},
              rightIcon: Icons.arrow_forward,
              isFullWidth: true,
            ),
            const SizedBox(height: 24),

            Text('States', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppButton.primary(
              label: 'Loading...',
              onPressed: null,
              isLoading: true,
              isFullWidth: true,
            ),
            const SizedBox(height: 8),
            AppButton.primary(
              label: 'Disabled',
              onPressed: null,
              isFullWidth: true,
            ),
            const SizedBox(height: 24),

            // Icon Buttons
            Text('Icon Buttons', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppIconButton.primary(icon: Icons.favorite, onPressed: () {}),
                AppIconButton.secondary(icon: Icons.bookmark, onPressed: () {}),
                AppIconButton.outlined(icon: Icons.share, onPressed: () {}),
                AppIconButton.outlined(
                  icon: Icons.add,
                  onPressed: () {},
                  customColor: AppColors.accent,
                ),
                AppIconButton.ghost(
                  icon: Icons.more_horiz,
                  onPressed: () {},
                  customColor: AppColors.primary,
                ),
                AppIconButton.ghost(
                  icon: Icons.more_horiz,
                  onPressed: () {},
                  customColor: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cards
            Text('Cards', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AppCard.light(
              child: const Text('Light card - white background'),
            ),
            const SizedBox(height: 8),
            AppCard.dark(
              child: const Text(
                'Dark card - burgundy background',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            AppCard.accent(
              child: const Text('Accent card - warm tint background'),
            ),
            const SizedBox(height: 8),
            AppCard.outlined(
              child: const Text('Outlined card - default gold border'),
            ),
            const SizedBox(height: 8),
            AppCard.outlined(
              customBorderColor: AppColors.error,
              child: Text(
                'Outlined card - custom red border',
                style: TextStyle(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 8),
            AppCard.light(
              onTap: () {},
              child: const Text('Tappable card - tap me'),
            ),
            const SizedBox(height: 8),
            AppCard.light(
              borderRadius: 32,
              child: const Text('Very rounded card'),
            ),
            const SizedBox(height: 8),
            AppCard.gradient(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SMART SUGGESTION',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You are 3 items away from making 12 new recipes.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton.outlined(
                    label: 'View Recipes',
                    onPressed: () {},
                    customColor: AppColors.accent,
                    customBorderColor: AppColors.accent,
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