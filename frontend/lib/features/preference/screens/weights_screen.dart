import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/feedback_provider.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_toast.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/preference_weights.dart';
import '../providers/weights_provider.dart';
import '../widgets/weight_slider.dart';
import '../widgets/weights_help_sheet.dart';

const double _blurArea = 220;
const double _sheetTop = 190;
const double _dismissDistance = 120;
const double _dismissVelocity = 700;

class WeightsScreen extends ConsumerStatefulWidget {
  const WeightsScreen({super.key});

  @override
  ConsumerState<WeightsScreen> createState() => _WeightsScreenState();
}

class _WeightsScreenState extends ConsumerState<WeightsScreen> {
  final _scroll = ScrollController();
  PreferenceWeights? _draft;
  bool _saving = false;
  double _drag = 0;
  bool _dragging = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;

    setState(() => _saving = true);
    final feedback = ref.read(feedbackProvider.notifier);
    try {
      await ref.read(weightsProvider.notifier).save(draft);
      feedback.showShort(
        'Recommendation settings saved',
        kind: ToastKind.success,
        icon: Icons.check_circle_outline,
      );
      if (mounted) context.pop();
    } catch (_) {
      feedback.showShort(
        'Could not save. Try again.',
        kind: ToastKind.error,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _dragBy(double dy) {
    setState(() {
      _dragging = true;
      _drag = (_drag + dy).clamp(0, double.infinity);
    });
  }

  void _release(double velocity) {
    if (!_dragging) return;
    if (_drag > _dismissDistance || velocity > _dismissVelocity) {
      context.pop();
      return;
    }
    setState(() {
      _dragging = false;
      _drag = 0;
    });
  }

  bool _onScroll(ScrollNotification n) {
    if (n is OverscrollNotification &&
        n.overscroll < 0 &&
        n.dragDetails != null) {
      _dragBy(-n.overscroll);
    } else if (n is ScrollUpdateNotification &&
        _drag > 0 &&
        n.dragDetails != null) {
      _dragBy(-(n.scrollDelta ?? 0));
    } else if (n is ScrollEndNotification) {
      _release(n.dragDetails?.primaryVelocity ?? 0);
    }
    return false;
  }

  void _set(int idx, double v) {
    setState(() => _draft = _draft!.rebalance(idx, v));
  }

    @override
  Widget build(BuildContext context) {
    final asyncWeights = ref.watch(weightsProvider);

    final loaded = asyncWeights.valueOrNull;
    if (_draft == null && loaded != null) _draft = loaded;

    final fade = 1 - (_drag / _dismissDistance).clamp(0.0, 1.0);

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
                duration: _dragging
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                opacity: fade,
                child: GestureDetector(
                  onVerticalDragUpdate: (d) => _dragBy(d.delta.dy),
                  onVerticalDragEnd: (d) => _release(d.primaryVelocity ?? 0),
                  child: _Header(
                    onBack: () => context.pop(),
                    onReset: _draft == null
                        ? null
                        : () =>
                            setState(() => _draft = PreferenceWeights.defaults),
                    onHelp: () => showWeightsHelp(context),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration:
                _dragging ? Duration.zero : const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            top: _sheetTop + _drag,
            bottom: -_drag,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bgCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    child: _draft == null
                        ? Center(
                            child: asyncWeights.hasError
                                ? Text(
                                    'Could not load your settings.',
                                    style: AppTextStyles.body
                                        .copyWith(color: AppColors.error),
                                  )
                                : const CircularProgressIndicator(),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: _onScroll,
                            child: _body(_draft!),
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

  Widget _body(PreferenceWeights weights) {
    return Scrollbar(
      controller: _scroll,
      thumbVisibility: true,
      child: ListView(
        controller: _scroll,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(
            'Recommendations',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Tune how your Discover feed is chosen',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 26),
          WeightSlider(
            title: 'Pantry Match',
            icon: Icons.kitchen_outlined,
            subtitle: 'Favour recipes you can make with what you already have',
            value: weights.pantryMatch,
            onChanged: (v) => _set(0, v),
          ),
          WeightSlider(
            title: 'Cuisine',
            icon: Icons.public,
            subtitle: 'Lean towards the cuisines you cook and swipe on most',
            value: weights.cuisine,
            onChanged: (v) => _set(1, v),
          ),
          WeightSlider(
            title: 'Nutrition',
            icon: Icons.monitor_heart_outlined,
            subtitle: 'Push recipes that match your nutritional goals',
            value: weights.nutrition,
            onChanged: (v) => _set(2, v),
          ),
          WeightSlider(
            title: 'Freshness',
            icon: Icons.eco_outlined,
            subtitle: 'Prioritise ingredients close to their expiry date',
            value: weights.freshness,
            onChanged: (v) => _set(3, v),
          ),
          WeightSlider(
            title: 'Novelty',
            icon: Icons.auto_awesome_outlined,
            subtitle: 'Bring more variety instead of familiar recipes',
            value: weights.novelty,
            onChanged: (v) => _set(4, v),
          ),
          const SizedBox(height: 8),
          AppButton.primary(
            label: 'Save Changes',
            onPressed: _save,
            isFullWidth: true,
            isRounded: true,
            isLoading: _saving,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onBack,
    required this.onReset,
    required this.onHelp,
  });

  final VoidCallback onBack;
  final VoidCallback? onReset;
  final VoidCallback onHelp;
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: onBack,
                    background: AppColors.textLight.withValues(alpha: 0.45),
                    iconColor: AppColors.textDark,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _CircleButton(
                        icon: Icons.restart_alt,
                        onTap: onReset,
                        background: AppColors.textLight.withValues(alpha: 0.45),
                        iconColor: AppColors.textDark,
                      ),
                      const SizedBox(height: 8),
                      _CircleButton(
                        icon: Icons.help_outline,
                        onTap: onHelp,
                        background: AppColors.textLight.withValues(alpha: 0.45),
                        iconColor: AppColors.textDark,
                      ),
                    ],
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(shape: BoxShape.circle, color: background),
        child: Icon(
          icon,
          size: 19,
          color: onTap == null ? AppColors.textMuted : iconColor,
        ),
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
