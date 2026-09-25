import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_edit_lock_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/shared_recipe_edit_provider.dart';
import 'add_recipe_screen.dart';

class SharedRecipeEditScreen extends ConsumerStatefulWidget {
  const SharedRecipeEditScreen({
    super.key,
    required this.target,
  });

  final SharedRecipeContext target;

  @override
  ConsumerState<SharedRecipeEditScreen> createState() =>
      _SharedRecipeEditScreenState();
}

class _SharedRecipeEditScreenState extends ConsumerState<SharedRecipeEditScreen>
    with WidgetsBindingObserver {
  late final VaultSession _session;

  Recipe? _recipe;
  String? _message;
  bool _checking = true;
  bool _saving = false;
  bool _active = true;
  bool _needsFreshRecipe = true;
  int _revision = 0;

  RecipeEditLockNotifier get _lock => ref.read(
        recipeEditLockProvider(widget.target.recipeId).notifier,
      );

  bool get _sameSession =>
      mounted && ref.read(vaultSessionProvider) == _session;

  bool get _canContinueSave =>
      _sameSession && _active && !_needsFreshRecipe && _lock.canSave;

  @override
  void initState() {
    super.initState();
    _session = ref.read(vaultSessionProvider);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_checkAndLoad());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    //auto-dispose lock provider performs best-effort release
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      _active = true;

      //an upload already in progress is allowed to finish, but next mutation cannot start until paused lock is checked again
      if (!_saving && !_checking) {
        unawaited(_checkAndLoad());
      }
      return;
    }

    _active = false;
    _lock.pause(
      message: 'Editing is paused while the app is in the background.',
    );
  }

  Future<bool> _checkAccess() async {
    if (!_sameSession ||
        !_active ||
        ref.read(vaultConnectionProvider) != NetworkStatus.online) {
      return false;
    }

    ref.invalidate(sharedRecipeEditAccessProvider(widget.target));

    final allowed = await ref.read(
      sharedRecipeEditAccessProvider(widget.target).future,
    );

    return _sameSession && _active && allowed;
  }

  Future<void> _checkAndLoad({bool discardDraft = false}) async {
    if (!mounted || _saving) return;

    setState(() {
      _checking = true;
      _message = null;
    });

    try {
      if (!await _checkAccess()) {
        if (!_sameSession) return;

        _lock.pause(
          message: 'Editing access is unavailable. Check your connection '
              'and shared-vault permissions.',
        );
        return;
      }

      await _lock.resume();
      if (!_sameSession || !_active) return;

      final lockState = ref.read(
        recipeEditLockProvider(widget.target.recipeId),
      );

      final reloadRequired =
          lockState.phase == RecipeEditLockPhase.reloadRequired;

      if (!_lock.canSave && !reloadRequired) return;

      if (reloadRequired) {
        _needsFreshRecipe = true;
      }

      //preserve existing draft until user explicitly agrees to replace it with latest server version
      if (_recipe != null && _needsFreshRecipe && !discardDraft) {
        return;
      }

      if (_recipe != null && !_needsFreshRecipe && !discardDraft) {
        return;
      }

      final acquiredAt = lockState.lock?.acquiredAt;
      if (acquiredAt == null) return;

      //use remote repository directly. Cached data must not establish baseline for new shared editing session
      final repository = ref.read(remoteRecipeRepositoryProvider);
      final id = widget.target.recipeId;

      bool stillHoldsLease() {
        if (!_sameSession || !_active) return false;

        final current = ref.read(recipeEditLockProvider(id));

        return current.lock?.acquiredAt == acquiredAt &&
            (_lock.canSave ||
                current.phase == RecipeEditLockPhase.reloadRequired);
      }

      final recipe = await repository.getRecipeById(id);
      if (!stillHoldsLease()) return;

      if (recipe.recipeId != id) {
        throw const FormatException('Unexpected recipe response.');
      }

      final ingredients = await repository.getRecipeIngredients(id);
      if (!stillHoldsLease()) return;

      final steps = await repository.getRecipeSteps(id);
      if (!stillHoldsLease()) return;

      final current = ref.read(recipeEditLockProvider(id));

      if (current.phase == RecipeEditLockPhase.reloadRequired) {
        if (!_lock.confirmReloaded(acquiredAt: acquiredAt)) return;
      }

      if (!_lock.canSave || !_sameSession || !_active) return;

      setState(() {
        _recipe = recipe.copyWith(
          ingredients: ingredients,
          steps: steps,
        );
        _needsFreshRecipe = false;
        _revision++;
      });
    } catch (_) {
      if (_sameSession) {
        setState(() {
          _message = 'Could not load the latest recipe or verify editing '
              'access. Your existing draft has been kept.';
        });

        _lock.pause(message: _message!);
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  Future<bool> _beforeSave() async {
    if (!_canContinueSave) return false;

    try {
      if (!await _checkAccess()) {
        if (_sameSession) {
          _lock.pause(
            message: 'Your editing access could not be verified. '
                'Your draft has been kept.',
          );
        }
        return false;
      }

      //refresh immediately before saving, in addition to provider's automatic 30-second renewal
      await _lock.acquire();
      return _canContinueSave;
    } catch (_) {
      if (_sameSession) {
        _lock.pause(
          message: 'Could not verify editing access. '
              'Your draft has been kept.',
        );
      }
      return false;
    }
  }

  void _saveFailed() {
    if (!_sameSession) return;

    setState(() => _needsFreshRecipe = true);
    _lock.pause(
      message: 'The save could not be confirmed. Your draft has been kept. '
          'Check access and reload the latest recipe before saving again.',
    );
  }

  Future<void> _saveComplete() async {
    if (!_sameSession) return;

    await _lock.close();
    if (!mounted || !_sameSession) return;

    ref.invalidate(recipeByIdProvider(widget.target.recipeId));
    ref.invalidate(recipeDetailProvider(widget.target.recipeId));
    ref.invalidate(recipesProvider);

    final message =
        ref.read(recipeEditLockProvider(widget.target.recipeId)).message;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    setState(() => _saving = false);

    //apply PopScope's updated state before editor navigates back
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _confirmReload() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reload latest recipe?'),
        content: const Text(
          'This replaces your unsaved draft, including selected photos '
          'and videos, with the latest saved recipe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep draft'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard draft and reload'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _checkAndLoad(discardDraft: true);
    }
  }

  void _leave() {
    if (_saving) return;

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/vault');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(
      recipeEditLockProvider(widget.target.recipeId),
    );
    ref.watch(vaultSessionProvider);
    ref.watch(vaultConnectionProvider);

    final editable = _recipe != null && !_checking && _canContinueSave;

    final needsReload = _recipe != null &&
        (_needsFreshRecipe ||
            lockState.phase == RecipeEditLockPhase.reloadRequired);

    final waiting = _checking ||
        _saving ||
        lockState.phase == RecipeEditLockPhase.acquiring ||
        lockState.phase == RecipeEditLockPhase.releasing;

    return PopScope(
      canPop: !_saving,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_recipe != null)
            Offstage(
              offstage: !editable,
              child: AbsorbPointer(
                absorbing: _saving,
                child: AddRecipeScreen(
                  key: ValueKey(_revision),
                  editRecipeId: widget.target.recipeId,
                  initialRecipe: _recipe,
                  beforeSave: _beforeSave,
                  canContinueSave: () => _canContinueSave,
                  onSavingChanged: (saving) {
                    if (mounted) {
                      setState(() => _saving = saving);
                    }
                  },
                  onSaveComplete: _saveComplete,
                  onSaveFailure: _saveFailed,
                ),
              ),
            ),
          if (!editable)
            Scaffold(
              backgroundColor: AppColors.bgLight,
              appBar: AppBar(
                backgroundColor: AppColors.bgLight,
                title: const Text('Edit shared recipe'),
                leading: IconButton(
                  tooltip: 'Back',
                  onPressed: _saving ? null : _leave,
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (waiting)
                        const CircularProgressIndicator()
                      else
                        const Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _checking
                            ? 'Checking access and loading the latest recipe…'
                            : lockState.message ??
                                _message ??
                                'Check editing access before continuing.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (_recipe != null) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Your draft stays here until you reload or leave.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (!waiting) ...[
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: needsReload
                              ? _confirmReload
                              : () => _checkAndLoad(),
                          child: Text(
                            needsReload
                                ? 'Reload latest recipe'
                                : 'Check again',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
