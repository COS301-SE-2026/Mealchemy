import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../recipe/models/recipe_step.dart';
import '../models/cook_narration_state.dart';
import '../models/cook_timer.dart';
import 'cook_active_timer.dart';

class CookStepStage extends StatelessWidget {
  const CookStepStage({
    super.key,
    required this.step,
    required this.narration,
    required this.activeTimer,
    required this.now,
  });

  final RecipeStep step;
  final CookNarrationState narration;
  final CookTimer? activeTimer;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                liveRegion: true,
                label: 'Step ${step.stepNr}. ${step.content}',
                child: ExcludeSemantics(
                  child: _HighlightedStepText(
                    text: step.content,
                    activeStart: narration.stepText == step.content
                        ? narration.activeStart
                        : null,
                    activeEnd: narration.stepText == step.content
                        ? narration.activeEnd
                        : null,
                  ),
                ),
              ),
              if (activeTimer != null) ...[
                const SizedBox(height: 40),
                CookActiveTimer(timer: activeTimer!, now: now),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedStepText extends StatelessWidget {
  const _HighlightedStepText({
    required this.text,
    required this.activeStart,
    required this.activeEnd,
  });

  final String text;
  final int? activeStart;
  final int? activeEnd;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.heading1.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w700,
      height: 1.35,
    );
    final start = activeStart;
    final end = activeEnd;
    final hasValidRange = start != null &&
        end != null &&
        start >= 0 &&
        end > start &&
        end <= text.length;

    if (!hasValidRange) {
      return Text(
        text,
        key: const Key('cook-step-text'),
        textAlign: TextAlign.center,
        style: style,
      );
    }

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: style.copyWith(
              backgroundColor: AppColors.accent.withValues(alpha: 0.38),
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      key: const Key('cook-step-text'),
      textAlign: TextAlign.center,
    );
  }
}
