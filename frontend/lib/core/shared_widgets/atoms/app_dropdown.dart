import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

enum DropdownIconTone { primary, accent }

class AppDropdownItem {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool destructive;

  const AppDropdownItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.destructive = false,
  });
}

class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.trigger,
    required this.items,
    this.iconTone = DropdownIconTone.primary,
  });

  final Widget trigger;
  final List<AppDropdownItem> items;
  final DropdownIconTone iconTone;

  Color get _iconColor =>
      iconTone == DropdownIconTone.accent ? AppColors.accent : AppColors.primary;

  Future<void> _open(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + box.size.height + 6,
      overlay.size.width - (topLeft.dx + box.size.width),
      0,
    );

    final picked = await showMenu<int>(
      context: context,
      position: position,
      color: Colors.transparent,
      elevation: 0,
      constraints: const BoxConstraints(minWidth: 220),
      items: [
        PopupMenuItem<int>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _MenuPanel(
            items: items,
            iconColor: _iconColor,
            onPick: (i) => Navigator.pop(context, i),
          ),
        ),
      ],
    );

    if (picked != null) items[picked].onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(12),
      child: trigger,
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.items,
    required this.iconColor,
    required this.onPick,
  });

  final List<AppDropdownItem> items;
  final Color iconColor;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              _MenuRow(
                item: items[i],
                iconColor: iconColor,
                onTap: () => onPick(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.item,
    required this.iconColor,
    required this.onTap,
  });

  final AppDropdownItem item;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = item.destructive ? AppColors.error : iconColor;
    final textColor = item.destructive ? AppColors.error : AppColors.textLight;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 20, color: tint),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                item.label,
                style: AppTextStyles.body.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}