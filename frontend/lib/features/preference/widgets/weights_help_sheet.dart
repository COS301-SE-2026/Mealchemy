import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class _Item {
  const _Item(this.icon, this.title, this.desc);
  final IconData icon;
  final String title;
  final String desc;
}

const _items = <_Item>[
  _Item(Icons.kitchen_outlined, 'Pantry Match',
      'Higher favours recipes you can cook with what is already in your pantry, so less shopping and less waste.'),
  _Item(Icons.public, 'Cuisine',
      'Higher leans your feed towards the cuisines you cook and swipe on most.'),
  _Item(Icons.monitor_heart_outlined, 'Nutrition',
      'Higher pushes recipes that line up with your nutritional goals.'),
  _Item(Icons.eco_outlined, 'Freshness',
      'Higher prioritises recipes that use ingredients close to their expiry date.'),
  _Item(Icons.auto_awesome_outlined, 'Novelty',
      'Higher brings more variety and new recipes; lower keeps things familiar.'),
];

Future<void> showWeightsHelp(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _Sheet(),
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How recommendations work',
              style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Each slider sets how much a signal counts. They are balanced '
              'against each other, so raising one lowers the share of the rest.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 22),
            for (final item in _items) ...[
              _Row(item),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.item);

  final _Item item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Badge(item.icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style:
                    AppTextStyles.bodyBold.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 2),
              Text(
                item.desc,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.textDark, size: 20),
    );
  }
}