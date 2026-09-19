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
import '../models/cook_timer.dart';
import '../models/cook_voice_command.dart';
import '../providers/cook_mode_provider.dart';
import '../providers/cook_narration_provider.dart';
import '../providers/cook_session_provider.dart';
import '../providers/cook_timer_provider.dart';
import '../providers/cook_voice_provider.dart';
import '../services/cook_duration_parser.dart';
import '../services/cook_session_store.dart';
import '../services/cook_voice_service.dart';
import '../services/screen_awake_service.dart';
import '../widgets/cook_mode_action_dock.dart';
import '../widgets/cook_step_stage.dart';
import '../widgets/cook_timer_controls.dart';
import '../widgets/cook_voice_indicator.dart';

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
  late final CookTimerController _timerController;
  late final CookVoiceService _voiceService;
  late final CookModeArgs _args;
  late final AppLifecycleListener _lifecycleListener;
  late final int? _userId;
  Future<void> _wakeOperation = Future<void>.value();
  Timer? _listenDelay;
  bool _isForeground = true;
  bool _restoringSession = true;
  bool _storageWarning = false;
  bool _voiceInitializing = false;
  bool _voiceInitialized = false;
  bool _voiceAvailable = false;
  bool _voiceModeEnabled = false;
  bool _voiceListening = false;
  bool _voiceSessionActive = false;
  bool _initialNarrationPending = true;
  String? _voiceMessage;
  double _voiceSoundLevel = 0;
  double _minimumSoundLevel = double.infinity;
  double _maximumSoundLevel = double.negativeInfinity;
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
    _userId = ref.read(activeIdentityProvider);
    _timerController = ref.read(
      cookTimerControllerProvider(_userId).notifier,
    );
    _voiceService = ref.read(cookVoiceServiceProvider);
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
    _maybeStartInitialNarration();
  }

  Future<void> _initializeVoice() async {
    if (_voiceInitializing || _voiceInitialized) return;
    setState(() => _voiceInitializing = true);
    try {
      final available = await _voiceService.initialize(CookVoiceCallbacks(
        onFinalResult: _onVoiceResult,
        onListeningChanged: _onListeningChanged,
        onSoundLevel: _onSoundLevel,
        onError: _onVoiceError,
      ));
      if (!mounted) return;
      setState(() {
        _voiceInitialized = available;
        _voiceAvailable = available;
        _voiceInitializing = false;
        if (!available) {
          _voiceModeEnabled = false;
          _voiceMessage = 'Voice unavailable on this device.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _voiceInitializing = false;
        _voiceInitialized = false;
        _voiceAvailable = false;
        _voiceModeEnabled = false;
        _voiceMessage = 'Voice unavailable on this device.';
      });
    }
  }

  void _maybeStartInitialNarration() {
    if (!_initialNarrationPending || _restoringSession || !_isForeground) {
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
    final shouldResume = !listening &&
        _voiceListening &&
        _voiceSessionActive &&
        _voiceModeEnabled;
    if (shouldResume) _voiceSessionActive = false;
    setState(() {
      _voiceListening = listening;
      if (listening) {
        _voiceMessage = null;
      } else {
        _voiceSoundLevel = 0;
      }
    });
    if (shouldResume) _scheduleListening();
  }

  void _onSoundLevel(double level) {
    if (!mounted || !_voiceListening || !level.isFinite) return;
    if (level < _minimumSoundLevel) _minimumSoundLevel = level;
    if (level > _maximumSoundLevel) _maximumSoundLevel = level;
    final range = _maximumSoundLevel - _minimumSoundLevel;
    final normalized = range < 1
        ? 0.35
        : ((level - _minimumSoundLevel) / range).clamp(0.0, 1.0).toDouble();
    setState(() => _voiceSoundLevel = normalized);
  }

  void _onVoiceError(String message) {
    if (!mounted || !_isForeground) return;
    _voiceSessionActive = false;
    final timedOut = message.contains('error_speech_timeout') ||
        message.contains('error_no_match');
    setState(() {
      _voiceListening = false;
      _voiceSoundLevel = 0;
      if (timedOut) {
        _voiceMessage = null;
      } else {
        _voiceModeEnabled = false;
        _voiceAvailable = false;
        _voiceInitialized = false;
        _voiceMessage = 'On-device voice unavailable. Tap Speak to try again.';
      }
    });
    if (timedOut && _voiceModeEnabled) _scheduleListening();
  }

  void _onVoiceResult(CookVoiceResult result) {
    if (!mounted || !_isForeground || !_voiceSessionActive) return;
    _voiceSessionActive = false;
    final command = parseCookVoiceIntent(result.words);
    if (command == null ||
        (result.confidence != null && result.confidence! < 0.5)) {
      setState(() {
        _voiceMessage =
            "Didn't catch that. Try next, back, repeat, or set a timer.";
      });
      unawaited(_restartVoiceListening());
      return;
    }

    final mode = ref.read(cookModeControllerProvider(_args));
    if (command.type == CookVoiceCommandType.back && !mode.canGoBack) {
      setState(() => _voiceMessage = 'Already at the first step.');
      unawaited(_restartVoiceListening());
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
    switch (command.type) {
      case CookVoiceCommandType.next:
        await _goNext();
      case CookVoiceCommandType.back:
        await _goBack();
      case CookVoiceCommandType.repeat:
        await _repeatStep();
      case CookVoiceCommandType.startTimer:
        await _startTimer(command.duration!, resumeListening: true);
      case CookVoiceCommandType.startSuggestedTimer:
        await _startSuggestedTimer(resumeListening: true);
    }
  }

  Future<void> _startSuggestedTimer({bool resumeListening = false}) async {
    final mode = ref.read(cookModeControllerProvider(_args));
    final duration = detectCookStepDuration(
      widget.steps[mode.currentStepIndex].content,
    );
    if (duration == null) {
      if (mounted) {
        setState(() {
          _voiceMessage = 'No clear timer duration was found in this step.';
        });
      }
      return;
    }
    await _startTimer(duration, resumeListening: resumeListening);
  }

  Future<void> _startTimer(
    Duration duration, {
    bool resumeListening = false,
  }) async {
    await _stopVoiceListening();
    if (!mounted) return;
    final mode = ref.read(cookModeControllerProvider(_args));
    final step = widget.steps[mode.currentStepIndex];
    await _timerController.start(
      recipeId: widget.recipe.recipeId,
      recipeTitle: widget.recipe.title,
      stepIndex: mode.currentStepIndex,
      stepNumber: step.stepNr,
      duration: duration,
    );
    if (!mounted) return;
    setState(() {
      _voiceMessage = '${formatCookDuration(duration)} timer started.';
    });
    if (resumeListening) _scheduleListening();
  }

  void _scheduleListening() {
    if (!_voiceModeEnabled ||
        !_voiceInitialized ||
        !_voiceAvailable ||
        !_isForeground ||
        _restoringSession) {
      return;
    }
    final generation = ++_voiceGeneration;
    _listenDelay?.cancel();
    _listenDelay = Timer(const Duration(milliseconds: 300), () {
      _listenDelay = null;
      if (!mounted ||
          generation != _voiceGeneration ||
          !_isForeground ||
          !_voiceModeEnabled) {
        return;
      }
      unawaited(_startVoiceListening());
    });
  }

  Future<void> _startVoiceListening() async {
    if (!mounted ||
        !_voiceAvailable ||
        !_voiceModeEnabled ||
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
    _minimumSoundLevel = double.infinity;
    _maximumSoundLevel = double.negativeInfinity;
    setState(() {
      _voiceMessage = null;
      _voiceSoundLevel = 0;
    });
    try {
      await _voiceService.listen();
    } catch (_) {
      if (!mounted) return;
      _voiceSessionActive = false;
      setState(() {
        _voiceListening = false;
        _voiceModeEnabled = false;
        _voiceAvailable = false;
        _voiceInitialized = false;
        _voiceMessage = 'Voice unavailable. Tap Speak to try again.';
      });
    }
  }

  Future<void> _stopVoiceListening() async {
    _voiceGeneration++;
    _listenDelay?.cancel();
    _listenDelay = null;
    _voiceSessionActive = false;
    try {
      await _voiceService.stop();
    } catch (_) {
      // Manual cooking remains available if the recognizer cannot stop.
    }
    if (mounted && _voiceListening) {
      setState(() {
        _voiceListening = false;
        _voiceSoundLevel = 0;
      });
    }
  }

  Future<void> _restartVoiceListening() async {
    await _stopVoiceListening();
    if (mounted && _voiceModeEnabled) _scheduleListening();
  }

  Future<void> _toggleVoiceMode() async {
    if (_voiceModeEnabled) {
      setState(() {
        _voiceModeEnabled = false;
        _voiceMessage = null;
      });
      await _stopVoiceListening();
      return;
    }

    setState(() {
      _voiceModeEnabled = true;
      _voiceMessage = null;
    });
    if (!_voiceInitialized) await _initializeVoice();
    if (!mounted || !_voiceModeEnabled || !_voiceAvailable) return;

    final narration = ref.read(
      cookNarrationControllerProvider(widget.recipe.recipeId),
    );
    if (!narration.isSpeaking &&
        !narration.isPaused &&
        narration.status != CookNarrationStatus.preparing) {
      _scheduleListening();
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
    if (_voiceModeEnabled) _scheduleListening();
  }

  Future<void> _pauseNarration() => _narrationController.pause();

  @override
  void dispose() {
    _voiceGeneration++;
    _listenDelay?.cancel();
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
    final timerState = ref.watch(cookTimerControllerProvider(_userId));
    final activeTimers = timerState.activeTimers;

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
              speechRate: narration.speechRate,
              canAdjustSpeechRate: !narration.isUnavailable,
              onSpeechRateChanged: (rate) =>
                  unawaited(_narrationController.setSpeechRate(rate)),
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
                child: CookStepStage(
                  step: widget.steps[state.currentStepIndex],
                  narration: narration,
                  activeTimers: activeTimers,
                  now: timerState.now,
                ),
              ),
              CookVoiceIndicator(
                isListening: _voiceListening,
                soundLevel: _voiceSoundLevel,
                message: _voiceMessage,
              ),
              CookTimerControls(
                state: timerState,
                suggestedDuration: detectCookStepDuration(
                  widget.steps[state.currentStepIndex].content,
                ),
                onStart: _startTimer,
                onCancel: _timerController.cancel,
              ),
              CookModeActionDock(
                narration: narration,
                canGoBack: state.canGoBack,
                isLastStep: state.isLastStep,
                isVoiceModeEnabled: _voiceModeEnabled,
                isVoiceInitializing: _voiceInitializing,
                isVoiceUnavailable: !_voiceInitializing &&
                    (_voiceMessage?.toLowerCase().contains('unavailable') ??
                        false),
                onBack: () => unawaited(_goBack()),
                onNarration: () => unawaited(_toggleNarration(narration)),
                onVoiceMode: () => unawaited(_toggleVoiceMode()),
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
  const _CookModeHeader({
    required this.recipeTitle,
    required this.onClose,
    required this.speechRate,
    required this.canAdjustSpeechRate,
    required this.onSpeechRateChanged,
  });

  final String recipeTitle;
  final VoidCallback onClose;
  final double speechRate;
  final bool canAdjustSpeechRate;
  final ValueChanged<double> onSpeechRateChanged;

  static const _speechRates = [0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65];

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
          PopupMenuButton<double>(
            key: const Key('narration-speed-menu'),
            tooltip: 'Narration speed',
            enabled: canAdjustSpeechRate,
            initialValue: speechRate,
            onSelected: onSpeechRateChanged,
            itemBuilder: (context) => _speechRates
                .map(
                  (rate) => CheckedPopupMenuItem<double>(
                    value: rate,
                    checked: rate == speechRate,
                    child: Text('${(rate * 2).toStringAsFixed(1)}x'),
                  ),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${(speechRate * 2).toStringAsFixed(1)}x',
                    style: AppTextStyles.caption.copyWith(
                      color: canAdjustSpeechRate
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w700,
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
