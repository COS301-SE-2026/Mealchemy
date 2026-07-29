import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class StepEditorRow extends StatelessWidget {
  const StepEditorRow({
    super.key,
    required this.stepNumber,
    required this.controller,
    required this.onRemove,
    this.showError = false,
  });

  final int stepNumber;
  final TextEditingController controller;
  final VoidCallback onRemove;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // step number badge
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(top: 6),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text('$stepNumber',
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.textDark)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Describe this step',
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                  ),
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textLight),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textMuted,
                tooltip: 'Remove',
              ),
            ],
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 2),
              child: Text('Step text is required.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.error)),
            ),
        ],
      ),
    );
  }
}