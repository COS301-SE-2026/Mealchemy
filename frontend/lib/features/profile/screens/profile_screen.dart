import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/feedback_provider.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_toast.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/profile_provider.dart';
import '../widgets/information_section.dart';
import '../widgets/preferences_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: const [
        _Intro(),
        SizedBox(height: 30),
        InformationSection(),
        SizedBox(height: 40),
        PreferencesSection(),
        SizedBox(height: 32),
        _SaveBar(),
      ],
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

// One save action commits both profile and preferences changes
class _SaveBar extends ConsumerWidget {
  const _SaveBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider).valueOrNull;
    final prefsState = ref.watch(preferencesProvider).valueOrNull;

    final profileDirty = profileState?.dirty ?? false;
    final prefsDirty = prefsState?.dirty ?? false;
    final anyDirty = profileDirty || prefsDirty;

    final saving = profileState?.saveStatus == SaveStatus.saving ||
        prefsState?.saveStatus == SaveStatus.saving;

    ref.listen(profileProvider, (_, next) => _reportError(ref, next));
    ref.listen(preferencesProvider, (_, next) => _reportError(ref, next));

    return AppButton(
      label: anyDirty ? 'Save Changes' : 'All Changes Saved',
      isLoading: saving,
      onPressed: anyDirty && !saving
          ? () async {
              final futures = <Future<void>>[];
              if (profileDirty) {
                futures.add(ref.read(profileProvider.notifier).save());
              }
              if (prefsDirty) {
                futures.add(ref.read(preferencesProvider.notifier).save());
              }
              await Future.wait(futures);

              final profileOk =
                  ref.read(profileProvider).valueOrNull?.saveStatus !=
                      SaveStatus.error;
              final prefsOk =
                  ref.read(preferencesProvider).valueOrNull?.saveStatus !=
                      SaveStatus.error;
              if (profileOk && prefsOk) {
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

  void _reportError(WidgetRef ref, AsyncValue next) {
    final state = next.valueOrNull;
    if (state?.saveStatus == SaveStatus.error) {
      ref.read(feedbackProvider.notifier).showShort(
            state?.errorMessage ?? 'Could not save. Try again.',
            kind: ToastKind.error,
            icon: Icons.error_outline,
          );
    }
  }
}