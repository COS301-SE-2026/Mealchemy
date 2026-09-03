import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/shared_widgets/atoms/app_card.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/link_provider.dart';
import 'link_row.dart';
import 'link_sheet.dart';

enum _LinkAction { add }

class MyLinksFolderRow extends ConsumerStatefulWidget {
  const MyLinksFolderRow({super.key});

  @override
  ConsumerState<MyLinksFolderRow> createState() => _MyLinksFolderRowState();
}
class _MyLinksFolderRowState extends ConsumerState<MyLinksFolderRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = ref.watch(offlineReadOnlyProvider);
    final linksAsync = ref.watch(linksProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _LinksAvatar(isOpen: _isExpanded),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                           'My Links',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textLight,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle(linksAsync),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tertiaryMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                  _LinksMenuButton(
                    enabled: !isReadOnly,
                    onAddLink: () => showLinkSheet(context: context),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard.light(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: linksAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Unable to load links.',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                ),
                data: (links) => links.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No links saved yet.',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      )
                    : Column(
                        children: [
                          for (final link in links)
                            LinkRow(
                              link: link,
                              mutationsEnabled: !isReadOnly,
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _subtitle(AsyncValue links) {
    return links.maybeWhen(
      data: (list) {
        final count = list.length;
        return '$count ${count == 1 ? 'link' : 'links'}';
      },
      orElse: () => 'Your saved recipes from the web',
    );
  }
}

class _LinksMenuButton extends StatelessWidget {
  const _LinksMenuButton({required this.enabled, required this.onAddLink});

  final bool enabled;
  final VoidCallback onAddLink;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_LinkAction>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.inputBorder.withValues(alpha: 0.95),
      ),
      color: AppColors.bgLight,
      elevation: 4,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      enabled: enabled,
      tooltip: enabled ? 'Link actions' : 'Unavailable offline',
      onSelected: (_) => onAddLink(),
      itemBuilder: (context) => [
        PopupMenuItem<_LinkAction>(
          value: _LinkAction.add,
          child: Row(
            children: [
              const Icon(Icons.add_link, size: 20, color: AppColors.accent),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Add a link',
                  style: AppTextStyles.title.copyWith(color: AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinksAvatar extends StatelessWidget {
  const _LinksAvatar({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isOpen ? Icons.link : Icons.link_outlined,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}