import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/atoms/app_chip.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../ingredients/providers/ingredient_catalogue_provider.dart';
import '../providers/profile_provider.dart';

// Disliked ingredients are catalogue backed not free text the user types,
class AversionsSection extends ConsumerStatefulWidget {
  const AversionsSection({super.key, required this.disliked});

  final List<String> disliked;

  @override
  ConsumerState<AversionsSection> createState() => _AversionsSectionState();
}

class _AversionsSectionState extends ConsumerState<AversionsSection> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _add(String name) {
    ref.read(preferencesProvider.notifier).addDislikedIngredient(name);
    _ctrl.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(preferencesProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField.standard(
          controller: _ctrl,
          hint: 'Search an ingredient to avoid',
          prefixIcon: Icons.search,
          onChanged: _onChanged,
        ),
        if (_query.length >= 2) _SearchResults(query: _query, onPick: _add),
        if (widget.disliked.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final name in widget.disliked)
                AppChip(
                  label: name,
                  variant: AppChipVariant.white,
                  onRemove: () => notifier.removeDislikedIngredient(name),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.onPick});

  final String query;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(catalogueSearchProvider(query));

    return resultsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 10),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          'Search failed. Try again.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        ),
      ),
      data: (hits) {
        if (hits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'No matches in the catalogue.',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < hits.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                InkWell(
                  onTap: () => onPick(hits[i].name),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.add,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            hits[i].name,
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}