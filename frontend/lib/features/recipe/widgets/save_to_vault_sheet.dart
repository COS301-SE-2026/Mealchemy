import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
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
      backgroundColor: AppColors.bgLight,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final vaultsAsync = ref.watch(vaultsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SAVE TO VAULT',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.accentMuted, letterSpacing: 2)),
          const SizedBox(height: 16),

          // vault picker
          Text('Vault',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          vaultsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => Text('Could not load vaults.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.error)),
            data: (vaults) => _vaultDropdown(vaults),
          ),
          const SizedBox(height: 16),

          // folder picker (depends on chosen vault)
          Text('Folder',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          if (_vaultId == null)
            _disabledField('Pick a vault first')
          else
            _folderPicker(_vaultId!),
          const SizedBox(height: 24),

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

  Widget _vaultDropdown(List<Vault> vaults) {
    return DropdownButtonFormField<int>(
      initialValue: _vaultId,
      isExpanded: true,
      decoration: _decoration(),
      hint: Text('Select a vault',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
      items: [
        for (final v in vaults)
          DropdownMenuItem<int>(
            value: v.vaultId,
            child: Row(
              children: [
                Icon(
                  v.vaultType == VaultTypes.private
                      ? Icons.lock
                      : Icons.group_outlined,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(v.name, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
      ],
      onChanged: (id) => setState(() {
        _vaultId = id;
        _folderId = null; // reset folder when vault changes
      }),
    );
  }

  Widget _folderPicker(int vaultId) {
    final foldersAsync = ref.watch(vaultFoldersProvider(vaultId));
    return foldersAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Text('Could not load folders.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
      data: (folders) {
        if (folders.isEmpty) {
          return _disabledField('No folders in this vault');
        }
        return DropdownButtonFormField<int>(
          initialValue: _folderId,
          isExpanded: true,
          decoration: _decoration(),
          hint: Text('Select a folder',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          items: [
            for (final VaultFolder f in folders)
              DropdownMenuItem<int>(
                value: f.folderId,
                child: Text(f.folderName),
              ),
          ],
          onChanged: (id) => setState(() => _folderId = id),
        );
      },
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(vaultRepositoryProvider)
          .addRecipeToFolder(_folderId!, widget.recipeId);
      ref.invalidate(vaultFoldersProvider(_vaultId!));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved to vault')),
        );
      }
    } catch (_) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Try again.')),
        );
      }
    }
  }

  Widget _disabledField(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Text(text,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
      );

  InputDecoration _decoration() => InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
      );
}