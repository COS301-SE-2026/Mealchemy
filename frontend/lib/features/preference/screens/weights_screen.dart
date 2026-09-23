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

class WeightsScreen extends ConsumerStatefulWidget {
  const WeightsScreen({super.key});

  @override
  ConsumerState<WeightsScreen> createState() => _WeightsScreenState();
}

class _WeightsScreenState extends ConsumerState<WeightsScreen> {
  final _scroll = ScrollController();
  PreferenceWeights? _draft;
  bool _saving = false;

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

  @override
  Widget build(BuildContext context) {
    ref.listen(weightsProvider, (_, next) {
      next.whenData((w) {
        if (_draft == null && mounted) setState(() => _draft = w);
      });
    });

    final asyncWeights = ref.watch(weightsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _blurArea,
            child: _Header(
              onBack: () => context.pop(),
              onReset: _draft == null
                  ? null
                  : () => setState(() => _draft = PreferenceWeights.defaults),
              onHelp: () => showWeightsHelp(context),
            ),
          ),
          Positioned.fill(
            top: _sheetTop,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bgCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
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
                  : _body(_draft!),
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
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: _SheetHandle(),
          ),
          const SizedBox(height: 16),
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
            share: weights.shareOf(weights.pantryMatch),
            onChanged: (v) =>
                setState(() => _draft = weights.copyWith(pantryMatch: v)),
          ),
          WeightSlider(
            title: 'Cuisine',
            icon: Icons.public,
            subtitle: 'Lean towards the cuisines you cook and swipe on most',
            value: weights.cuisine,
            share: weights.shareOf(weights.cuisine),
            onChanged: (v) =>
                setState(() => _draft = weights.copyWith(cuisine: v)),
          ),
          WeightSlider(
            title: 'Nutrition',
            icon: Icons.monitor_heart_outlined,
            subtitle: 'Push recipes that match your nutritional goals',
            value: weights.nutrition,
            share: weights.shareOf(weights.nutrition),
            onChanged: (v) =>
                setState(() => _draft = weights.copyWith(nutrition: v)),
          ),
          WeightSlider(
            title: 'Freshness',
            icon: Icons.eco_outlined,
            subtitle: 'Prioritise ingredients close to their expiry date',
            value: weights.freshness,
            share: weights.shareOf(weights.freshness),
            onChanged: (v) =>
                setState(() => _draft = weights.copyWith(freshness: v)),
          ),
          WeightSlider(
            title: 'Novelty',
            icon: Icons.auto_awesome_outlined,
            subtitle: 'Bring more variety instead of familiar recipes',
            value: weights.novelty,
            share: weights.shareOf(weights.novelty),
            onChanged: (v) =>
                setState(() => _draft = weights.copyWith(novelty: v)),
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
