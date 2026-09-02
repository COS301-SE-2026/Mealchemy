import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/feedback_provider.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/shared_widgets/atoms/app_toast.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/link.dart';
import '../providers/link_provider.dart';

// Create or edit a link. Pass an existing link to edit it, or null to create.
Future<void> showLinkSheet({
  required BuildContext context,
  Link? link,
}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surfaceWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: _LinkSheet(link: link),
    ),
  );
}

class _LinkSheet extends ConsumerStatefulWidget {
  const _LinkSheet({this.link});
  final Link? link;

  @override
  ConsumerState<_LinkSheet> createState() => _LinkSheetState();
}

class _LinkSheetState extends ConsumerState<_LinkSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _urlCtrl;

  String? _nameError;
  String? _urlError;
  bool _saving = false;

  bool get _isEditing => widget.link != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.link?.name ?? '');
    _urlCtrl = TextEditingController(text: widget.link?.url ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 24),
          Text(
            'NAME',
            style: AppTextStyles.label
                .copyWith(color: AppColors.brown, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          AppTextField.standard(
            controller: _nameCtrl,
            hint: 'e.g. Creamy Garlic Pasta',
            prefixIcon: Icons.label_outline,
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 18),
          Text(
            'LINK',
            style: AppTextStyles.label
                .copyWith(color: AppColors.brown, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          AppTextField.standard(
            controller: _urlCtrl,
            hint: 'https://...',
            prefixIcon: Icons.link,
            keyboardType: TextInputType.url,
            errorText: _urlError,
            onChanged: (_) {
              if (_urlError != null) setState(() => _urlError = null);
            },
          ),
          const SizedBox(height: 26),
          AppButton.primary(
            label: _isEditing ? 'Save Changes' : 'Add Link',
            isFullWidth: true,
            isRounded: true,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
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
          child: const Icon(Icons.link, color: AppColors.textDark, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MY LINKS',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.accentMuted, letterSpacing: 2),
              ),
              const SizedBox(height: 2),
              Text(
                _isEditing ? 'Edit Link' : 'Add a Link',
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.primary, fontSize: 22),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _validate() {
    final name = _nameCtrl.text.trim();
    final url = _urlCtrl.text.trim();

    String? nameError;
    String? urlError;

    if (name.isEmpty) {
      nameError = 'Give the link a name.';
    } else if (name.length > 150) {
      nameError = 'Keep the name under 150 characters.';
    }
    if (url.isEmpty) {
      urlError = 'Add a link.';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      urlError = 'Link must start with http:// or https://';
    }

    setState(() {
      _nameError = nameError;
      _urlError = urlError;
    });

    return nameError == null && urlError == null;
  }

  Future<void> _save() async {
    if (!_validate()) return;

    setState(() => _saving = true);
    final feedback = ref.read(feedbackProvider.notifier);
    final notifier = ref.read(linksProvider.notifier);
    final name = _nameCtrl.text.trim();
    final url = _urlCtrl.text.trim();

    try {
      if (_isEditing) {
        await notifier.editLink(
          linkId: widget.link!.linkId,
          name: name,
          url: url,
        );
      } else {
        await notifier.addLink(name: name, url: url);
      }
      if (mounted) Navigator.pop(context);
      feedback.showShort(
        _isEditing ? 'Link updated' : 'Link added',
        kind: ToastKind.success,
        icon: Icons.check_circle_outline,
      );
    } catch (_) {
      setState(() => _saving = false);
      feedback.showShort(
        'Could not save the link. Check the name and link.',
        kind: ToastKind.error,
        icon: Icons.error_outline,
      );
    }
  }
}