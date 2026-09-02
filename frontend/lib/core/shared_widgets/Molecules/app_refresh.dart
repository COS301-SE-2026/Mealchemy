import 'package:flutter/material.dart';

import '../../theme/app_colours.dart';

// Standardises the pull-to-refresh look brand colour across screens.
// Each screen supplies onRefresh to reload its own providers.
class AppRefresh extends StatelessWidget {
  const AppRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceWhite,
      displacement: 28,
      child: child,
    );
  }
}