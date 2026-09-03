import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../connectivity/network_status_provider.dart';
import '../routes/app_routes.dart';

class OfflineStatusFrame extends ConsumerWidget {
  const OfflineStatusFrame({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusProvider);
    final requiresReauthentication = ref.watch(
      authProvider.select((state) => state.requiresReauthentication),
    );
    final showOffline = status == NetworkStatus.offline;
    final showChecking = status == NetworkStatus.checking;
    final showReauthentication =
        status == NetworkStatus.online && requiresReauthentication;
    final showBanner = showOffline || showChecking || showReauthentication;

    return Column(
      children: [
        if (showBanner)
          _StatusBanner(
            status: status,
            requiresReauthentication: showReauthentication,
            onSignIn:
                showReauthentication ? () => context.go(AppRoutes.login) : null,
          ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: showBanner,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.status,
    required this.requiresReauthentication,
    this.onSignIn,
  });

  final NetworkStatus status;
  final bool requiresReauthentication;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isChecking = status == NetworkStatus.checking;
    final icon = requiresReauthentication
        ? Icons.lock_outline
        : isChecking
            ? Icons.sync
            : Icons.cloud_off_outlined;
    final message = requiresReauthentication
        ? 'Sign in to sync changes'
        : isChecking
            ? 'Checking connection'
            : 'Offline - showing saved data';

    return Material(
      color: requiresReauthentication
          ? colorScheme.tertiaryContainer
          : colorScheme.surfaceContainerHighest,
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.onSurface),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (onSignIn != null)
                  IconButton(
                    onPressed: onSignIn,
                    icon: const Icon(Icons.login),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
