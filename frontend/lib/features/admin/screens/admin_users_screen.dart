import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/admin_access_provider.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_access_message.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(adminAccessStateProvider);
    final session = ref.watch(adminAccessContextProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage admins'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.admin);
            }
          },
        ),
      ),
      body: SafeArea(
        child: access == AdminAccess.allowed
            ? _AdminUsersForm(
                key: ValueKey((session.userId, session.token)),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: AdminAccessMessage(access: access),
              ),
      ),
    );
  }
}

class _AdminUsersForm extends ConsumerStatefulWidget {
  const _AdminUsersForm({super.key});

  @override
  ConsumerState<_AdminUsersForm> createState() => _AdminUsersFormState();
}

class _AdminUsersFormState extends ConsumerState<_AdminUsersForm> {
  final _emailController = TextEditingController();
  bool _confirming = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _confirmPromotion() async {
    if (_confirming || !ref.read(adminUsersEnabledProvider)) return;

    final state = ref.read(adminUsersProvider);
    final user = state.user;

    if (user == null ||
        user.isAdmin ||
        state.isPromoting ||
        state.isSearching) {
      return;
    }

    final session = ref.read(adminAccessContextProvider);
    setState(() => _confirming = true);

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Promote to administrator?',
      message: '${user.displayName}\n${user.email}\n\n'
          'This user will be able to review community reports, remove '
          'recipes from the community, and promote other administrators.',
      confirmLabel: 'Promote',
    );

    if (!mounted) return;

    setState(() => _confirming = false);
    if (confirmed != true) return;

    await ref.read(adminUsersProvider.notifier).promote(
          confirmedUser: user,
          confirmedSession: session,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);
    final enabled = ref.watch(adminUsersEnabledProvider);
    final user = state.user;

    final busy = state.isSearching || state.isPromoting || _confirming;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Administrator access',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Find an existing user by email, then confirm their promotion.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Email address',
          hint: 'jane@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          errorText: state.emailError,
          enabled: !state.isPromoting && !_confirming,
          onChanged: (value) =>
              ref.read(adminUsersProvider.notifier).changeEmail(value),
          onSubmitted: (_) {
            if (enabled && !busy) {
              ref.read(adminUsersProvider.notifier).search();
            }
          },
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Find user',
          isFullWidth: true,
          isLoading: state.isSearching,
          onPressed: enabled && !busy
              ? () => ref.read(adminUsersProvider.notifier).search()
              : null,
        ),
        if (!enabled) ...[
          const SizedBox(height: 12),
          Text(
            'Connect to the internet with a valid admin session to continue.',
            style: AppTextStyles.body,
          ),
        ],
        if (state.message != null) ...[
          const SizedBox(height: 20),
          Semantics(
            liveRegion: true,
            child: Text(
              state.message!,
              style: AppTextStyles.bodyBold.copyWith(
                color: state.isError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
        if (user != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Text(user.email, style: AppTextStyles.body),
                const SizedBox(height: 8),
                Text(
                  'Roles: ${user.roles.join(', ')}',
                  style: AppTextStyles.body,
                ),
                if (!user.isAdmin) ...[
                  const SizedBox(height: 20),
                  AppButton.outlined(
                    label: 'Promote to admin',
                    isFullWidth: true,
                    isLoading: state.isPromoting,
                    onPressed: enabled && !busy ? _confirmPromotion : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
