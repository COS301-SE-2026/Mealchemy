import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_icon_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../recipe/models/recipe.dart';
import '../../recipe/models/recipe_step.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../providers/cook_mode_provider.dart';
import '../services/screen_awake_service.dart';

class CookModeScreen extends ConsumerWidget {
  const CookModeScreen({super.key, required this.recipeId});

  final int recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeState = ref.watch(recipeDetailProvider(recipeId));

    return recipeState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _CookModeMessage(
        title: 'Unable to start Cook Mode',
        message: 'This recipe could not be loaded.',
        icon: Icons.error_outline,
        onClose: () => context.pop(),
      ),
      data: (recipe) {
        final steps = [...?recipe.steps]
          ..sort((a, b) => a.stepNr.compareTo(b.stepNr));
        if (steps.isEmpty) {
          return _CookModeMessage(
            title: 'No cooking steps yet',
            message: 'Add preparation steps before starting Cook Mode.',
            icon: Icons.menu_book_outlined,
            onClose: () => context.pop(),
          );
        }
        return _CookModeContent(recipe: recipe, steps: steps);
      },
    );
  }
}

class _CookModeContent extends ConsumerStatefulWidget {
  const _CookModeContent({required this.recipe, required this.steps});

  final Recipe recipe;
  final List<RecipeStep> steps;

  @override
  ConsumerState<_CookModeContent> createState() => _CookModeContentState();
}

class _CookModeContentState extends ConsumerState<_CookModeContent> {
  late final ScreenAwakeService _screenAwakeService;
  late final CookModeArgs _args;

  @override
  void initState() {
    super.initState();
    _args = CookModeArgs(
      recipeId: widget.recipe.recipeId,
      stepCount: widget.steps.length,
    );
    _screenAwakeService = ref.read(screenAwakeServiceProvider);
    unawaited(_setScreenAwake(true));
  }

  Future<void> _setScreenAwake(bool enabled) async {
    try {
      if (enabled) {
        await _screenAwakeService.enable();
      } else {
        await _screenAwakeService.disable();
      }
    } catch (_) {
      // Cook Mode remains fully usable when a platform wakelock is unavailable.
    }
  }

  @override
  void dispose() {
    unawaited(_setScreenAwake(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cookModeControllerProvider(_args));
    final controller = ref.read(cookModeControllerProvider(_args).notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _CookModeHeader(
              recipeTitle: widget.recipe.title,
              onClose: () => context.pop(),
            ),
            if (!state.isCompleted) ...[
              _StepProgress(
                currentStep: state.currentStepIndex + 1,
                totalSteps: state.totalSteps,
                progress: state.progress,
              ),
              Expanded(
                child: _StepContent(
                  step: widget.steps[state.currentStepIndex],
                ),
              ),
              _CookControls(
                canGoBack: state.canGoBack,
                isLastStep: state.isLastStep,
                onBack: controller.back,
                onNext: controller.next,
              ),
            ] else
              Expanded(
                child: _CompletionView(
                  recipeTitle: widget.recipe.title,
                  onCookAgain: controller.restart,
                  onClose: () => context.pop(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CookModeHeader extends StatelessWidget {
  const _CookModeHeader({required this.recipeTitle, required this.onClose});

  final String recipeTitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          Tooltip(
            message: 'Close Cook Mode',
            child: AppIconButton.ghost(
              icon: Icons.close,
              onPressed: onClose,
              customColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recipeTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.progress,
  });

  final int currentStep;
  final int totalSteps;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step $currentStep of $totalSteps',
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step});

  final RecipeStep step;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
          child: Center(
            child: Semantics(
              liveRegion: true,
              label: 'Step ${step.stepNr}. ${step.content}',
              child: Text(
                step.content,
                key: const Key('cook-step-text'),
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CookControls extends StatelessWidget {
  const _CookControls({
    required this.canGoBack,
    required this.isLastStep,
    required this.onBack,
    required this.onNext,
  });

  final bool canGoBack;
  final bool isLastStep;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            Tooltip(
              message: 'Previous step',
              child: AppIconButton.outlined(
                icon: Icons.arrow_back,
                onPressed: canGoBack ? onBack : null,
                size: 56,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.primary(
                key: const Key('cook-next-button'),
                label: isLastStep ? 'Finish' : 'Next step',
                onPressed: onNext,
                rightIcon: isLastStep ? Icons.check : Icons.arrow_forward,
                isFullWidth: true,
                size: ButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({
    required this.recipeTitle,
    required this.onCookAgain,
    required this.onClose,
  });

  final String recipeTitle;
  final VoidCallback onCookAgain;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 28),
          Text(
            'Ready to serve',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading1.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            recipeTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 36),
          AppButton.primary(
            label: 'Back to recipe',
            onPressed: onClose,
            leftIcon: Icons.menu_book_outlined,
            isFullWidth: true,
            size: ButtonSize.large,
          ),
          const SizedBox(height: 12),
          AppButton.text(
            label: 'Cook again',
            onPressed: onCookAgain,
            leftIcon: Icons.replay,
          ),
        ],
      ),
    );
  }
}

class _CookModeMessage extends StatelessWidget {
  const _CookModeMessage({
    required this.title,
    required this.message,
    required this.icon,
    required this.onClose,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: 'Close Cook Mode',
                  child: AppIconButton.ghost(
                    icon: Icons.close,
                    onPressed: onClose,
                    customColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 56, color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
