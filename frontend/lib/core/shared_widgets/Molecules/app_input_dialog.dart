import 'package:flutter/material.dart';
import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';
import '../atoms/app_button.dart';
import '../atoms/app_text_field.dart';

// Centered single field dialog. Returns the entered text if submitted,
Future<String?> showAppInputDialog({
  required BuildContext context,
  required String title,
  required String label,
  required String hint,
  String confirmLabel = 'Save',
  String? initialValue,
  IconData? prefixIcon,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) => _InputDialogBody(
      title: title,
      label: label,
      hint: hint,
      confirmLabel: confirmLabel,
      controller: controller,
      prefixIcon: prefixIcon,
    ),
  );
}

class _InputDialogBody extends StatefulWidget {
  const _InputDialogBody({
    required this.title,
    required this.label,
    required this.hint,
    required this.confirmLabel,
    required this.controller,
    this.prefixIcon,
  });

  final String title;
  final String label;
  final String hint;
  final String confirmLabel;
  final TextEditingController controller;
  final IconData? prefixIcon;

  @override
  State<_InputDialogBody> createState() => _InputDialogBodyState();
}

class _InputDialogBodyState extends State<_InputDialogBody> {
  bool _showError = false;

  void _submit() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField.standard(
              controller: widget.controller,
              label: widget.label,
              hint: widget.hint,
              prefixIcon: widget.prefixIcon,
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
            ),
            if (_showError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'This field is required.',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    label: 'Cancel',
                    isRounded: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.primary(
                    label: widget.confirmLabel,
                    isRounded: true,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
