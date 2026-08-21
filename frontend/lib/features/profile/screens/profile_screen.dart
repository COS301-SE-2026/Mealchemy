import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/feedback_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Organisms/app_navbar.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_toast.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/profile_provider.dart';
import '../widgets/information_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.help),
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
          ),
        ],
      ),
      bottomNavigationBar: AppNavbar(
        currentRoute: AppRoutes.profile,
        onRouteSelected: (route) => context.go(route),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: const [
            _Intro(),
            SizedBox(height: 30),
            InformationSection(),
            SizedBox(height: 32),
            _SaveBar(),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERSONALIZED CURATION',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your Culinary\nProfile',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Fine-tune how Mealchemy curates for you. Everything here shapes the '
          'recommendations you see across the app.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _SaveBar extends ConsumerWidget {
  const _SaveBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider).valueOrNull;

    final dirty = profileState?.dirty ?? false;
    final saving = profileState?.saveStatus == SaveStatus.saving;

    ref.listen(profileProvider, (_, next) {
      final status = next.valueOrNull?.saveStatus;
      if (status == SaveStatus.error) {
        ref.read(feedbackProvider.notifier).showShort(
              next.valueOrNull?.errorMessage ?? 'Could not save. Try again.',
              kind: ToastKind.error,
              icon: Icons.error_outline,
            );
      }
    });

    return AppButton(
      label: dirty ? 'Save Changes' : 'All Changes Saved',
      isLoading: saving,
      onPressed: dirty && !saving
          ? () async {
              await ref.read(profileProvider.notifier).save();
              final saved =
                  ref.read(profileProvider).valueOrNull?.saveStatus ==
                      SaveStatus.success;
              if (saved) {
                ref.read(feedbackProvider.notifier).showShort(
                      'Profile updated',
                      kind: ToastKind.success,
                      icon: Icons.check_circle_outline,
                    );
              }
            }
          : null,
    );
  }
}