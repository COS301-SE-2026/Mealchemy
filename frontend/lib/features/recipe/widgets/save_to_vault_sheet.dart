import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_input_dialog.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_picker.dart';
import '../../../core/shared_widgets/atoms/app_toast.dart';
import '../../../core/providers/feedback_provider.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../vault/models/vault.dart';
import '../../vault/models/vault_folder.dart';
import '../../vault/providers/vault_provider.dart';
import '../../vault/providers/vault_repository_provider.dart';

// You pick a vault, then a folder in it, then save the recipe into that folder.
Future<void> showSaveToVaultSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int recipeId,
}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surfaceWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: _SaveToVaultSheet(recipeId: recipeId),
    ),
  );
}

class _SaveToVaultSheet extends ConsumerStatefulWidget {
  const _SaveToVaultSheet({required this.recipeId});
  final int recipeId;

  @override
  ConsumerState<_SaveToVaultSheet> createState() => _SaveToVaultSheetState();
}

class _SaveToVaultSheetState extends ConsumerState<_SaveToVaultSheet> {
  int? _vaultId;
  int? _folderId;
  String? _folderName;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final vaultsAsync = ref.watch(vaultsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 24),

          Text('VAULT',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.brown, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          vaultsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => Text('Could not load vaults.',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            data: (vaults) => _vaultPicker(vaults),
          ),
          const SizedBox(height: 18),

          Text('FOLDER',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.brown, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          if (_vaultId == null)
            _disabledField('Pick a vault first')
          else
            _folderSection(_vaultId!),
          const SizedBox(height: 26),

          AppButton.primary(
            label: 'Save Recipe',
            isFullWidth: true,
            isRounded: true,
            isLoading: _saving,
            onPressed: (_folderId == null || _saving) ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.brand,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.bookmark_add_outlined,
              color: AppColors.textDark, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VAULT',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.accentMuted, letterSpacing: 2)),
              const SizedBox(height: 2),
              Text('Save to Vault',
                  style: AppTextStyles.heading2
                      .copyWith(color: AppColors.primary, fontSize: 22)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vaultPicker(List<Vault> vaults) {
    return AppPicker<int>(
      value: _vaultId,
      hint: 'Select a vault',
      iconTone: PickerIconTone.accent,
      options: [
        for (final v in vaults)
          AppPickerOption(
            value: v.vaultId,
            label: v.name,
            icon: v.vaultType == VaultTypes.private
                ? Icons.lock
                : Icons.group_outlined,
          ),
      ],
      onChanged: (id) => setState(() {
        _vaultId = id;
        _folderId = null; // reset folder when vault changes
        _folderName = null;
      }),
    );
  }

  Widget _folderSection(int vaultId) {
    final foldersAsync = ref.watch(vaultFoldersProvider(vaultId));
    return foldersAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Text('Could not load folders.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
      data: (folders) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (folders.isEmpty)
              _disabledField('No folders in this vault yet')
            else
              AppPicker<int>(
                value: folders.any((f) => f.folderId == _folderId)
                    ? _folderId
                    : null,
                hint: 'Select a folder',
                iconTone: PickerIconTone.accent,
                options: [
                  for (final VaultFolder f in folders)
                    AppPickerOption(
                      value: f.folderId,
                      label: f.folderName,
                      icon: Icons.folder_outlined,
                    ),
                ],
                onChanged: (id) => setState(() {
                  _folderId = id;
                  _folderName =
                      folders.firstWhere((f) => f.folderId == id).folderName;
                }),
              ),
            const SizedBox(height: 12),
            AppButton.dashed(
              label: 'CREATE A FOLDER',
              onPressed: _createFolder,
              leftIcon: Icons.create_new_folder_outlined,
              isFullWidth: true,
            ),
          ],
        );
      },
    );
  }

  Future<void> _createFolder() async {
    if (_vaultId == null) return;
    final name = await showAppInputDialog(
      context: context,
      title: 'Create Folder',
      label: 'Folder Name',
      hint: 'e.g. Weeknight Dinners',
      confirmLabel: 'Create',
      prefixIcon: Icons.folder_outlined,
    );
    if (name == null) return;

    final feedback = ref.read(feedbackProvider.notifier);
    try {
      final created =
          await ref.read(vaultRepositoryProvider).createFolder(_vaultId!, name);
      final folders = await ref.refresh(vaultFoldersProvider(_vaultId!).future);
      if (!mounted) return;
      setState(() {
        _folderId = created.folderId;
        _folderName = folders
            .firstWhere((f) => f.folderId == created.folderId)
            .folderName;
      });
      feedback.showShort(
        'Folder "${created.folderName}" created',
        kind: ToastKind.success,
        icon: Icons.create_new_folder,
      );
    } catch (_) {
      feedback.showShort(
        'Could not create folder. Try again.',
        kind: ToastKind.error,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final feedback = ref.read(feedbackProvider.notifier);
    final folderName = _folderName;
    try {
      await ref
          .read(vaultRepositoryProvider)
          .addRecipeToFolder(_folderId!, widget.recipeId);
      ref.invalidate(vaultFoldersProvider(_vaultId!));
      ref.invalidate(folderRecipesProvider(_folderId!));
      ref.invalidate(folderRecipeDisplayProvider(_folderId!));
      if (mounted) Navigator.pop(context);
      feedback.showShort(
        folderName != null ? 'Saved to $folderName' : 'Recipe saved to vault',
        kind: ToastKind.success,
        icon: Icons.bookmark_added,
      );
    } catch (_) {
      setState(() => _saving = false);
      feedback.showShort(
        'Could not save. Try again.',
        kind: ToastKind.error,
        icon: Icons.error_outline,
      );
    }
  }

  Widget _disabledField(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Text(text,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
      );
}