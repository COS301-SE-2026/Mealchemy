import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe.dart';
import '../providers/recipe_report_provider.dart';

class ReportRecipeButton extends StatelessWidget {
  const ReportRecipeButton({
    super.key,
    required this.recipe,
    this.onImage = false,
  });

  final Recipe recipe;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    if (!recipe.isCommunityPublished || recipe.recipeId <= 0) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Report recipe',
      style: IconButton.styleFrom(
        foregroundColor: onImage ? Colors.white : AppColors.primary,
        backgroundColor: onImage ? Colors.black54 : Colors.transparent,
      ),
      icon: const Icon(Icons.flag_outlined),
      onPressed: () {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => ReportRecipeDialog(recipe: recipe),
        );
      },
    );
  }
}

class ReportRecipeDialog extends ConsumerWidget {
  const ReportRecipeDialog({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(recipeReportSessionProvider);

    return _ReportRecipeForm(
      key: ValueKey((recipe.recipeId, session)),
      recipe: recipe,
      session: session,
    );
  }
}

class _ReportRecipeForm extends ConsumerStatefulWidget {
  const _ReportRecipeForm({
    super.key,
    required this.recipe,
    required this.session,
  });

  final Recipe recipe;
  final RecipeReportSession session;

  @override
  ConsumerState<_ReportRecipeForm> createState() => _ReportRecipeFormState();
}

class _ReportRecipeFormState extends ConsumerState<_ReportRecipeForm> {
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(
      recipeReportProvider(widget.recipe.recipeId),
    );
    final unavailable = ref.watch(recipeReportUnavailableMessageProvider);

    final canLoadReasons = unavailable == null && !operation.isComplete;

    final reasonsState =
        canLoadReasons ? ref.watch(recipeReportReasonsProvider) : null;

    final reasons = reasonsState?.valueOrNull;
    final validSelection = reasonsState != null &&
        !reasonsState.isLoading &&
        !reasonsState.hasError &&
        reasons != null &&
        reasons.any((reason) => reason.value == _selectedReason);

    return PopScope(
      canPop: !operation.isSubmitting,
      child: Dialog(
        backgroundColor: AppColors.bgLight,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Report recipe',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close report',
                      onPressed: operation.isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.recipe.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!operation.isComplete) ...[
                          Text(
                            'What’s wrong with this recipe?',
                            style: AppTextStyles.bodyBold,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose the reason that best describes the '
                            'problem. An administrator will review your report.',
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (!operation.isComplete && unavailable != null)
                          Text(
                            unavailable,
                            style: AppTextStyles.body,
                          ),
                        if (canLoadReasons && reasonsState != null)
                          if (reasonsState.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (reasonsState.hasError) ...[
                            Text(
                              recipeReportErrorMessage(
                                reasonsState.error!,
                              ),
                              style: AppTextStyles.body,
                            ),
                            TextButton(
                              onPressed: operation.isSubmitting
                                  ? null
                                  : () {
                                      setState(() => _selectedReason = null);
                                      ref.invalidate(
                                        recipeReportReasonsProvider,
                                      );
                                    },
                              child: const Text('Retry reasons'),
                            ),
                          ] else if (reasons == null || reasons.isEmpty)
                            Text(
                              'No report reasons are currently available. '
                              'Please try again later.',
                              style: AppTextStyles.body,
                            )
                          else
                            ...reasons.map(
                              (reason) => Semantics(
                                checked: _selectedReason == reason.value,
                                inMutuallyExclusiveGroup: true,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    _selectedReason == reason.value
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    reason.label,
                                    style: AppTextStyles.body,
                                  ),
                                  enabled: !operation.isSubmitting,
                                  onTap: operation.isSubmitting
                                      ? null
                                      : () => setState(
                                            () =>
                                                _selectedReason = reason.value,
                                          ),
                                ),
                              ),
                            ),
                        if (operation.message != null) ...[
                          const SizedBox(height: 12),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              operation.message!,
                              style: AppTextStyles.body.copyWith(
                                color: operation.isComplete
                                    ? AppColors.primary
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (operation.isComplete)
                  AppButton.primary(
                    label: 'Done',
                    isFullWidth: true,
                    onPressed: () => Navigator.of(context).pop(),
                  )
                else
                  AppButton.primary(
                    label: 'Submit report',
                    isFullWidth: true,
                    isLoading: operation.isSubmitting,
                    onPressed: unavailable == null &&
                            validSelection &&
                            !operation.isSubmitting
                        ? () {
                            ref
                                .read(
                                  recipeReportProvider(
                                    widget.recipe.recipeId,
                                  ).notifier,
                                )
                                .submit(
                                  reasonValue: _selectedReason!,
                                  confirmedSession: widget.session,
                                );
                          }
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
