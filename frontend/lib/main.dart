import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/connectivity/network_status_provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/shared_widgets/atoms/app_toast_host.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: _NetworkStatusBootstrap(child: MealchemyApp()),
    ),
  );
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
      builder: (context, child) => AppToastHost(child: child),
    );
  }
}
