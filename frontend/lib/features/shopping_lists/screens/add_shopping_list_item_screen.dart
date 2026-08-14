import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

// Dedicated entry screen for adding an item to one shopping list.
// We will build the catalogue/custom form into this screen step by step.
class AddShoppingListItemScreen extends ConsumerStatefulWidget {
  const AddShoppingListItemScreen({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  ConsumerState<AddShoppingListItemScreen> createState() =>
      _AddShoppingListItemScreenState();
}

class _AddShoppingListItemScreenState
    extends ConsumerState<AddShoppingListItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.bgCream,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          'Shopping List Entry',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Add an item to shopping list ${widget.listId}',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }
}
