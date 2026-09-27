import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/notification_realtime_provider.dart';
import '../services/notification_realtime_service.dart';

class NotificationRealtimeBootstrap extends ConsumerStatefulWidget {
  const NotificationRealtimeBootstrap({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<NotificationRealtimeBootstrap> createState() =>
      _NotificationRealtimeBootstrapState();
}

class _NotificationRealtimeBootstrapState
    extends ConsumerState<NotificationRealtimeBootstrap>
    with WidgetsBindingObserver {
  late final NotificationRealtimeService _service;

  @override
  void initState() {
    super.initState();

    _service = ref.read(notificationRealtimeProvider);

    WidgetsBinding.instance.addObserver(this);
    appRouter.routeInformationProvider.addListener(_routeChanged);

    unawaited(Future<void>.microtask(() {
      if (!mounted) return;

      _updateInboxVisibility();

      final lifecycle = WidgetsBinding.instance.lifecycleState;
      _service.setForeground(
        lifecycle == null || lifecycle == AppLifecycleState.resumed,
      );
    }));
  }

  void _updateInboxVisibility() {
    _service.setInboxVisible(
      appRouter.routeInformationProvider.value.uri.path ==
          AppRoutes.notifications,
    );
  }

  void _routeChanged() {
    unawaited(Future<void>.microtask(() {
      if (mounted) _updateInboxVisibility();
    }));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(Future<void>.microtask(() {
      if (!mounted) return;
      _service.setForeground(state == AppLifecycleState.resumed);
    }));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouter.routeInformationProvider.removeListener(_routeChanged);

    //provider owns disposal, wrapper owns foreground activity
    unawaited(Future<void>.microtask(
      () => _service.setForeground(false),
    ));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
