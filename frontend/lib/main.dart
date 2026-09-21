import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/connectivity/network_status_provider.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/shared_widgets/atoms/app_toast_host.dart';
import 'core/shared_widgets/offline_status_frame.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cook_mode/models/cook_timer.dart';
import 'features/cook_mode/providers/cook_timer_provider.dart';
import 'features/cook_mode/services/cook_timer_notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: _CookTimerNotificationBootstrap(
        child: _NetworkStatusBootstrap(child: MealchemyApp()),
      ),
    ),
  );
}

class _CookTimerNotificationBootstrap extends ConsumerStatefulWidget {
  const _CookTimerNotificationBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_CookTimerNotificationBootstrap> createState() =>
      _CookTimerNotificationBootstrapState();
}

class _CookTimerNotificationBootstrapState
    extends ConsumerState<_CookTimerNotificationBootstrap> {
  late final FlutterLocalNotificationsCookTimerService _notificationService;
  late final StreamSubscription<CookTimerDestination> _tapSubscription;
  late final ProviderSubscription<AuthState> _authSubscription;
  CookTimerDestination? _pendingDestination;

  @override
  void initState() {
    super.initState();
    ref.read(authProvider);
    _notificationService = ref.read(
      flutterCookTimerNotificationServiceProvider,
    );
    _tapSubscription = _notificationService.taps.listen(_handleDestination);
    _authSubscription = ref.listenManual<AuthState>(
      authProvider,
      (previous, next) {
        final destination = _pendingDestination;
        if (next.hasValidCredential && destination != null) {
          _pendingDestination = null;
          _navigateTo(destination);
        }
      },
    );
    unawaited(_initializeNotificationHandling());
  }

  Future<void> _initializeNotificationHandling() async {
    final destination = await _notificationService.initializeTapHandling();
    if (destination != null) _handleDestination(destination);
  }

  void _handleDestination(CookTimerDestination destination) {
    if (!mounted) return;
    if (ref.read(authProvider).hasValidCredential) {
      _navigateTo(destination);
    } else {
      _pendingDestination = destination;
    }
  }

  void _navigateTo(CookTimerDestination destination) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      appRouter.go(
        AppRoutes.cookModeLocation(
          destination.recipeId,
          stepIndex: destination.stepIndex,
        ),
      );
    });
  }

  @override
  void dispose() {
    _tapSubscription.cancel();
    _authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _NetworkStatusBootstrap extends ConsumerStatefulWidget {
  const _NetworkStatusBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_NetworkStatusBootstrap> createState() =>
      _NetworkStatusBootstrapState();
}

class _NetworkStatusBootstrapState
    extends ConsumerState<_NetworkStatusBootstrap> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(networkStatusProvider.notifier).initialize());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MealchemyApp extends StatelessWidget {
  const MealchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mealchemy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      builder: (context, child) => OfflineStatusFrame(
        child: AppToastHost(child: child),
      ),
    );
  }
}
