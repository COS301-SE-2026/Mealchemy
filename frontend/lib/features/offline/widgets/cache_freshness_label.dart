import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/theme/app_colours.dart';
import '../providers/offline_cache_provider.dart';

class CacheFreshnessLabel extends ConsumerWidget {
  const CacheFreshnessLabel({
    super.key,
    required this.collection,
    required this.scopeId,
  });

  final String collection;
  final String scopeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(offlineReadOnlyProvider)) return const SizedBox.shrink();
    final metadata = ref.watch(
      cacheSyncMetadataProvider(
        CacheMetadataKey(collection: collection, scopeId: scopeId),
      ),
    );
    final syncedAt = metadata.valueOrNull?.lastSyncedAt;
    if (syncedAt == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.history, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            _relativeTime(syncedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ),
      ],
    );
  }

  String _relativeTime(DateTime syncedAt) {
    final elapsed = DateTime.now().toUtc().difference(syncedAt.toUtc());
    if (elapsed.inMinutes < 1) return 'Saved just now';
    if (elapsed.inHours < 1) return 'Saved ${elapsed.inMinutes}m ago';
    if (elapsed.inDays < 1) return 'Saved ${elapsed.inHours}h ago';
    return 'Saved ${elapsed.inDays}d ago';
  }
}
