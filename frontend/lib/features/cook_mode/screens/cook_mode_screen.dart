import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_icon_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../../recipe/models/recipe.dart';
import '../../recipe/models/recipe_step.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../models/cook_narration_state.dart';
import '../models/cook_session.dart';
import '../models/cook_voice_command.dart';
import '../providers/cook_mode_provider.dart';
import '../providers/cook_narration_provider.dart';
import '../providers/cook_session_provider.dart';
import '../providers/cook_voice_provider.dart';
import '../services/cook_session_store.dart';
import '../services/cook_voice_service.dart';
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
  late final CookNarrationController _narrationController;
  late final CookSessionController _sessionController;
  late final CookSessionStore _sessionStore;
  late final CookVoiceService _voiceService;
  late final CookModeArgs _args;
  late final AppLifecycleListener _lifecycleListener;
  late final int? _userId;
  Future<void> _wakeOperation = Future<void>.value();
  bool _isForeground = true;
  bool _restoringSession = true;
  bool _storageWarning = false;
  bool _voiceInitializing = true;
  bool _voiceAvailable = false;
  bool _voiceListening = false;
  bool _voiceSessionActive = false;
  bool _initialNarrationPending = true;
  String? _voiceMessage;
  int _voiceGeneration = 0;

  @override
  void initState() {
    super.initState();
    _args = CookModeArgs(
      recipeId: widget.recipe.recipeId,
      stepCount: widget.steps.length,
    );
    _screenAwakeService = ref.read(screenAwakeServiceProvider);
    _narrationController = ref.read(
      cookNarrationControllerProvider(widget.recipe.recipeId).notifier,
    );
    _sessionController = ref.read(cookSessionControllerProvider.notifier);
    _sessionStore = ref.read(cookSessionStoreProvider);
    _voiceService = ref.read(cookVoiceServiceProvider);
    _userId = ref.read(activeIdentityProvider);
    _lifecycleListener = AppLifecycleListener(
      onInactive: _onBackground,
      onHide: _onBackground,
      onPause: _onBackground,
      onResume: _onForeground,
    );
    unawaited(_setScreenAwake(true));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_restoreSession());
    });
  }

  Future<void> _setScreenAwake(bool enabled) {
    _wakeOperation = _wakeOperation.then((_) async {
      try {
        if (enabled) {
          await _screenAwakeService.enable();
        } else {
          await _screenAwakeService.disable();
        }
      } catch (_) {
        // Cook Mode remains usable when a platform wakelock is unavailable.
      }
    });
    return _wakeOperation;
  }

  Future<void> _restoreSession() async {
    var stepIndex = 0;
    final userId = _userId;
    if (userId != null) {
      try {
        final saved = await _sessionStore.read(userId, widget.recipe.recipeId);
        stepIndex = saved?.matchingStepIndex(widget.steps) ?? 0;
      } catch (_) {
        _showStorageWarning();
      }
    }

    if (!mounted) return;
    ref.read(cookModeControllerProvider(_args).notifier).restore(stepIndex);
    setState(() => _restoringSession = false);
    unawaited(_recordSession(stepIndex));
    unawaited(_initializeVoice());
  }

  Future<void> _initializeVoice() async {
    try {
      final available = await _voiceService.initialize(CookVoiceCallbacks(
        onFinalResult: _onVoiceResult,
        onListeningChanged: _onListeningChanged,
        onError: _onVoiceError,
      ));
      if (!mounted) return;
      setState(() {
        _voiceAvailable = available;
        _voiceMessage = available ? null : 'Voice unavailable on this device.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _voiceMessage = 'Voice unavailable on this device.');
    } finally {
      if (mounted) {
        setState(() => _voiceInitializing = false);
        _maybeStartInitialNarration();
      }
    }
  }

  void _maybeStartInitialNarration() {
    if (!_initialNarrationPending ||
        _voiceInitializing ||
        _restoringSession ||
        !_isForeground) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_initialNarrationPending || !_isForeground) return;
      _initialNarrationPending = false;
      final index =
          ref.read(cookModeControllerProvider(_args)).currentStepIndex;
      unawaited(_narrationController.speakStep(widget.steps[index].content));
    });
  }

  void _onListeningChanged(bool listening) {
    if (!mounted) return;
    setState(() {
      _voiceListening = listening;
      if (listening) _voiceMessage = null;
    });
  }

  void _onVoiceError(String message) {
    if (!mounted || !_isForeground) return;
    _voiceSessionActive = false;
    final timedOut = message.contains('error_speech_timeout') ||
        message.contains('error_no_match');
    setState(() {
      _voiceListening = false;
      _voiceMessage = timedOut
          ? 'Voice ready'
          : 'On-device voice unavailable. Tap the mic to try again.';
    });
  }

  void _onVoiceResult(CookVoiceResult result) {
    if (!mounted || !_isForeground || !_voiceSessionActive) return;
    _voiceSessionActive = false;
    final command = parseCookVoiceCommand(result.words);
    if (command == null ||
        (result.confidence != null && result.confidence! < 0.5)) {
      setState(() {
        _voiceMessage = "Didn't catch that. Try next, back, or repeat.";
      });
      unawaited(_stopVoiceListening());
      return;
    }

    final mode = ref.read(cookModeControllerProvider(_args));
    if (command == CookVoiceCommand.back && !mode.canGoBack) {
      setState(() => _voiceMessage = 'Already at the first step.');
      unawaited(_stopVoiceListening());
      return;
    }

    unawaited(_confirmVoiceCommand());
    unawaited(_runVoiceCommand(command));
  }

  Future<void> _confirmVoiceCommand() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Audio feedback is optional when the system sound is unavailable.
    }
  }

  Future<void> _runVoiceCommand(CookVoiceCommand command) async {
    switch (command) {
      case CookVoiceCommand.next:
        await _goNext();
      case CookVoiceCommand.back:
        await _goBack();
      case CookVoiceCommand.repeat:
        await _repeatStep();
    }
  }

  void _scheduleListening() {
    if (!_voiceAvailable || !_isForeground || _restoringSession) return;
    final generation = ++_voiceGeneration;
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || generation != _voiceGeneration || !_isForeground) return;
      unawaited(_startVoiceListening());
    });
  }

  Future<void> _startVoiceListening() async {
    if (!mounted ||
        !_voiceAvailable ||
        !_isForeground ||
        _restoringSession ||
        _voiceSessionActive) {
      return;
    }
    final narration = ref.read(
      cookNarrationControllerProvider(widget.recipe.recipeId),
    );
    final mode = ref.read(cookModeControllerProvider(_args));
    if (mode.isCompleted ||
        narration.isSpeaking ||
        narration.status == CookNarrationStatus.preparing ||
        narration.isPaused) {
      return;
    }

    _voiceGeneration++;
    _voiceSessionActive = true;
    setState(() => _voiceMessage = null);
    try {
      await _voiceService.listen();
    } catch (_) {
      if (!mounted) return;
      _voiceSessionActive = false;
      setState(() {
        _voiceListening = false;
        _voiceMessage = 'Voice unavailable. Tap the mic to try again.';
      });
    }
  }

  Future<void> _stopVoiceListening() async {
    _voiceGeneration++;
    _voiceSessionActive = false;
    try {
      await _voiceService.stop();
    } catch (_) {
      // Manual cooking remains available if the recognizer cannot stop.
    }
    if (mounted && _voiceListening) {
      setState(() => _voiceListening = false);
    }
  }

  Future<void> _toggleVoiceListening() async {
    if (_voiceListening) {
      await _stopVoiceListening();
    } else {
      await _stopVoiceListening();
      await _startVoiceListening();
    }
  }

  Future<void> _repeatStep() async {
    _initialNarrationPending = false;
    await _stopVoiceListening();
    if (!mounted) return;
    final index = ref.read(cookModeControllerProvider(_args)).currentStepIndex;
    await _narrationController.speakStep(widget.steps[index].content);
  }

  Future<void> _toggleNarration(CookNarrationState narration) async {
    _initialNarrationPending = false;
    if (narration.isSpeaking) {
      await _pauseNarration();
      return;
    }
    await _stopVoiceListening();
    if (!mounted) return;
    if (narration.isPaused) {
      await _narrationController.resume();
    } else {
      final index =
          ref.read(cookModeControllerProvider(_args)).currentStepIndex;
      await _narrationController.speakStep(widget.steps[index].content);
    }
  }

  Future<void> _recordSession(int stepIndex) async {
    final userId = _userId;
    if (userId == null) return;
    final step = widget.steps[stepIndex];
    try {
      await _sessionController.save(
        userId,
        CookSession(
          recipeId: widget.recipe.recipeId,
          recipeTitle: widget.recipe.title,
          stepIndex: stepIndex,
          stepNumber: step.stepNr,
          stepId: step.stepId,
          stepText: step.content,
          stepCount: widget.steps.length,
          savedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      _showStorageWarning();
    }
  }

  Future<void> _removeSession() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await _sessionController.remove(userId, widget.recipe.recipeId);
    } catch (_) {
      _showStorageWarning();
    }
  }

  void _showStorageWarning() {
    if (mounted && !_storageWarning) {
      setState(() => _storageWarning = true);
    }
  }

  void _onBackground() {
    if (!_isForeground) return;
    _isForeground = false;
    unawaited(_stopVoiceListening());
    unawaited(_pauseNarration());
    unawaited(_setScreenAwake(false));
  }

  void _onForeground() {
    if (_isForeground) return;
    _isForeground = true;
    unawaited(_setScreenAwake(true));
    _maybeStartInitialNarration();
  }

  Future<void> _pauseNarration() => _narrationController.pause();

  @override
  void dispose() {
    _voiceGeneration++;
    _voiceService.detach();
    unawaited(_voiceService.stop().catchError((_) {}));
    _lifecycleListener.dispose();
    unawaited(_narrationController.stop());
    unawaited(_setScreenAwake(false));
    super.dispose();
  }

  Future<void> _goNext() async {
    _initialNarrationPending = false;
    await _stopVoiceListening();
    if (!mounted) return;
    final controller = ref.read(cookModeControllerProvider(_args).notifier);
    controller.next();
    final nextState = ref.read(cookModeControllerProvider(_args));
    if (nextState.isCompleted) {
      await _narrationController.stop();
      unawaited(_removeSession());
      return;
    }
    unawaited(_recordSession(nextState.currentStepIndex));
    await _narrationController
        .speakStep(widget.steps[nextState.currentStepIndex].content);
  }

  Future<void> _goBack() async {
    _initialNarrationPending = false;
    await _stopVoiceListening();
    if (!mounted) return;
    final controller = ref.read(cookModeControllerProvider(_args).notifier);
    controller.back();
    final nextState = ref.read(cookModeControllerProvider(_args));
    unawaited(_recordSession(nextState.currentStepIndex));
    await _narrationController
        .speakStep(widget.steps[nextState.currentStepIndex].content);
  }

  Future<void> _restart() async {
    _initialNarrationPending = false;
    await _stopVoiceListening();
    if (!mounted) return;
    ref.read(cookModeControllerProvider(_args).notifier).restart();
    unawaited(_recordSession(0));
    await _narrationController.speakStep(widget.steps.first.content);
  }

  Future<void> _close() async {
    await _stopVoiceListening();
    await _narrationController.stop();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CookNarrationState>(
      cookNarrationControllerProvider(widget.recipe.recipeId),
      (previous, next) {
        if (next.status == CookNarrationStatus.completed &&
            previous?.status != CookNarrationStatus.completed) {
          _scheduleListening();
        } else if (next.status == CookNarrationStatus.preparing ||
            next.status == CookNarrationStatus.speaking ||
            next.status == CookNarrationStatus.paused ||
            next.status == CookNarrationStatus.unavailable) {
          _voiceGeneration++;
          if (_voiceSessionActive) unawaited(_stopVoiceListening());
        }
      },
    );
    final state = ref.watch(cookModeControllerProvider(_args));
    final narration =
        ref.watch(cookNarrationControllerProvider(widget.recipe.recipeId));

    if (_restoringSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _CookModeHeader(
              recipeTitle: widget.recipe.title,
              onClose: () => unawaited(_close()),
            ),
            if (_storageWarning)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Cooking progress could not be saved on this device.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
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
                  narration: narration,
                ),
              ),
              _NarrationControls(
                narration: narration,
                onToggle: () => unawaited(_toggleNarration(narration)),
                onRepeat: () => unawaited(_repeatStep()),
              ),
              _VoiceControls(
                isInitializing: _voiceInitializing,
                isAvailable: _voiceAvailable,
                isListening: _voiceListening,
                message: _voiceMessage,
                onToggle: () => unawaited(_toggleVoiceListening()),
              ),
              _CookControls(
                canGoBack: state.canGoBack,
                isLastStep: state.isLastStep,
                onBack: () => unawaited(_goBack()),
                onNext: () => unawaited(_goNext()),
              ),
            ] else
              Expanded(
                child: _CompletionView(
                  recipeTitle: widget.recipe.title,
                  onCookAgain: () => unawaited(_restart()),
                  onClose: () => unawaited(_close()),
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
  const _StepContent({required this.step, required this.narration});

  final RecipeStep step;
  final CookNarrationState narration;

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

class _NarrationControls extends StatelessWidget {
  const _NarrationControls({
    required this.narration,
    required this.onToggle,
    required this.onRepeat,
  });

  final CookNarrationState narration;
  final VoidCallback onToggle;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (narration.status) {
      CookNarrationStatus.preparing => (
          'Preparing narration',
          Icons.more_horiz
        ),
      CookNarrationStatus.speaking => ('Reading aloud', Icons.pause),
      CookNarrationStatus.paused => ('Narration paused', Icons.play_arrow),
      CookNarrationStatus.completed => ('Read again', Icons.volume_up_outlined),
      CookNarrationStatus.unavailable => (
          'Narration unavailable',
          Icons.volume_off_outlined
        ),
      CookNarrationStatus.idle => ('Read step aloud', Icons.volume_up_outlined),
    };
    final canControl = !narration.isUnavailable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: label,
            child: AppIconButton.primary(
              icon: icon,
              onPressed: canControl ? onToggle : null,
              size: 52,
              isLoading: narration.status == CookNarrationStatus.preparing,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyBold.copyWith(
              color: narration.isUnavailable
                  ? AppColors.error
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Repeat step',
            child: AppIconButton.ghost(
              icon: Icons.replay,
              onPressed: canControl ? onRepeat : null,
              customColor: AppColors.primary,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceControls extends StatelessWidget {
  const _VoiceControls({
    required this.isInitializing,
    required this.isAvailable,
    required this.isListening,
    required this.message,
    required this.onToggle,
  });

  final bool isInitializing;
  final bool isAvailable;
  final bool isListening;
  final String? message;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final label = isInitializing
        ? 'Preparing voice'
        : !isAvailable
            ? message ?? 'Voice unavailable'
            : isListening
                ? 'Listening'
                : message ?? 'Voice ready';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: isListening
                ? 'Stop listening'
                : 'Listen for next, back, or repeat',
            child: AppIconButton.outlined(
              icon: isAvailable
                  ? isListening
                      ? Icons.mic
                      : Icons.mic_none
                  : Icons.mic_off,
              onPressed: isAvailable && !isInitializing ? onToggle : null,
              size: 48,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: isAvailable
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.textMuted,
              ),
            ),
          ),
        ],
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
