import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

const double _blurArea = 140;
const double _sheetTop = 110;
const double _dismissDistance = 120;
const double _dismissVelocity = 700;

Future<T?> showSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, _, __) => builder(ctx),
      transitionsBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.15), end: Offset.zero)
                .animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

class MealPlanSheet extends ConsumerStatefulWidget {
  const MealPlanSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.footer,
    this.readOnlyWhenOffline = false,
    this.offlineMessage = 'You can still view everything, changes will be back once you reconnect.',
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;
  final bool readOnlyWhenOffline;
  final String offlineMessage;

  @override
  ConsumerState<MealPlanSheet> createState() => _SheetState();
}

class _SheetState extends ConsumerState<MealPlanSheet> {
  double _drag = 0;
  bool _dragging = false;

  void _dismiss() => Navigator.of(context).maybePop();

  void _dragBy(double dy) {
    setState(() {
      _dragging = true;
      _drag = (_drag + dy).clamp(0, double.infinity);
    });
  }

  void _release(double velocity) {
    if (!_dragging) return;
    if (_drag > _dismissDistance || velocity > _dismissVelocity) {
      _dismiss();
      return;
    }
    setState(() {
      _dragging = false;
      _drag = 0;
    });
  }


  bool _onScroll(ScrollNotification n) {
    if (n is OverscrollNotification && n.overscroll < 0 && n.dragDetails != null) {
      _dragBy(-n.overscroll);
    } else if (n is ScrollUpdateNotification && _drag > 0 && n.dragDetails != null) {
      _dragBy(-(n.scrollDelta ?? 0));
    } else if (n is ScrollEndNotification) {
      _release(n.dragDetails?.primaryVelocity ?? 0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final offline = widget.readOnlyWhenOffline && ref.watch(offlineReadOnlyProvider);
    final fade = 1 - (_drag / _dismissDistance).clamp(0.0, 1.0);
    final duration = _dragging ? Duration.zero : const Duration(milliseconds: 220);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _blurArea,
            child: IgnorePointer(
              ignoring: fade == 0,
              child: AnimatedOpacity(
                duration: duration,
                opacity: fade,
                child: GestureDetector(
                  onVerticalDragUpdate: (d) => _dragBy(d.delta.dy),
                  onVerticalDragEnd: (d) => _release(d.primaryVelocity ?? 0),
                  child: _BlurHeader(onBack: _dismiss),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: duration,
            curve: Curves.easeOut,
            top: _sheetTop + _drag,
            bottom: -_drag,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bgCream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (d) => _dragBy(d.delta.dy),
                    onVerticalDragEnd: (d) => _release(d.primaryVelocity ?? 0),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: _SheetHandle()),
                    ),
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScroll,
                      child: ListView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        children: [
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                          const SizedBox(height: 26),
                          if (offline)
                            _OfflineNotice(message: widget.offlineMessage)
                          else ...[
                            ...widget.children,
                            if (widget.footer != null) ...[
                              const SizedBox(height: 36),
                              widget.footer!,
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurHeader extends StatelessWidget {
  const _BlurHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _blurArea,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const DecoratedBox(
                decoration: BoxDecoration(color: AppColors.overlayLight),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textLight.withValues(alpha: 0.45),
                    ),
                    child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 19),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.tertiaryMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Changes are unavailable offline',
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}