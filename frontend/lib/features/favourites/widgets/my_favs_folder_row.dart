import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/fav_provider.dart';
import 'fav_row.dart';

class MyFavsFolderRow extends ConsumerStatefulWidget {
  const MyFavsFolderRow({super.key});

  @override
  ConsumerState<MyFavsFolderRow> createState() => _MyFavsFolderRowState();
}

class _MyFavsFolderRowState extends ConsumerState<MyFavsFolderRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = ref.watch(offlineReadOnlyProvider);
    final favsAsync = ref.watch(favsProvider);

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
                  _FavsAvatar(isOpen: _isExpanded),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Favourites',
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
                          _subtitle(favsAsync),
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
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: favsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Unable to load favourites.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
              data: (favs) => favs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No favourites yet.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    )
                  : Column(
                      children: [
                        for (final fav in favs)
                          FavRow(
                            fav: fav,
                            mutationsEnabled: !isReadOnly,
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  String _subtitle(AsyncValue favs) {
    return favs.maybeWhen(
      data: (list) {
        final count = list.length;
        return '$count ${count == 1 ? 'favourite' : 'favourites'}';
      },
      orElse: () => 'Your favourited recipes',
    );
  }
}

class _FavsAvatar extends StatelessWidget {
  const _FavsAvatar({required this.isOpen});

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
        isOpen ? Icons.favorite : Icons.favorite_border,
        color: AppColors.error,
        size: 24,
      ),
    );
  }
}