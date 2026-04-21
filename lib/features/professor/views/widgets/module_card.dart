import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../modules/models/course_module.dart';
import 'module_item_row.dart';

/// A module header + its items, in a single card. Items render in order.
/// An `Add item` button sits at the bottom — tapping fires [onAddItem].
class ModuleCard extends StatelessWidget {
  const ModuleCard({
    required this.module,
    required this.onAddItem,
    super.key,
  });

  final CourseModule module;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: Radii.card,
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: Radii.button,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${module.position + 1}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  module.title,
                  style: theme.textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (module.items.isEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text(
              'No items yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const SizedBox(height: Spacing.sm),
            const Divider(height: 1),
            for (final item in module.items) ModuleItemRow(item: item),
          ],
          const SizedBox(height: Spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add item'),
            ),
          ),
        ],
      ),
    );
  }
}
