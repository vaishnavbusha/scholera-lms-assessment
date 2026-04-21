import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../models/roadmap_module.dart';
import 'roadmap_item_card.dart';

/// A module header + its roadmap items stacked underneath. Separator between
/// modules is handled by the parent list.
class RoadmapModuleSection extends StatelessWidget {
  const RoadmapModuleSection({
    required this.module,
    this.onProfessorStatusChanged,
    this.onStudentStatusChanged,
    super.key,
  });

  final RoadmapModule module;

  /// Per-item callback for the professor coverage picker.
  final void Function(String itemId, dynamic status)? onProfessorStatusChanged;

  /// Per-item callback for the student progress picker.
  final void Function(String itemId, dynamic status)? onStudentStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        const SizedBox(height: Spacing.md),
        if (module.items.isEmpty)
          const EmptyState(
            icon: Icons.hourglass_empty,
            title: 'No items in this module yet',
            message:
                'Topics and coverage will show up here after the first item is added.',
            compact: true,
          )
        else
          for (final (index, item) in module.items.indexed) ...[
            if (index > 0) const SizedBox(height: Spacing.md),
            RoadmapItemCard(
              item: item,
              onProfessorStatusChanged: onProfessorStatusChanged == null
                  ? null
                  : (status) =>
                      onProfessorStatusChanged!(item.id, status),
              onStudentStatusChanged: onStudentStatusChanged == null
                  ? null
                  : (status) => onStudentStatusChanged!(item.id, status),
            ),
          ],
      ],
    );
  }
}
