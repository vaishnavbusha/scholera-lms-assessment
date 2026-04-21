import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// AI-extracted topic label. Sits under a module item on the roadmap.
///
/// Uses the active role's primary color as a small left-side dot so
/// admin/professor/student views can host the same chips and still feel
/// distinct from one another. Per-side border colors aren't used because
/// Flutter's DecoratedBox requires uniform border colors whenever a
/// borderRadius is applied.
class TopicChip extends StatelessWidget {
  const TopicChip({required this.label, this.confidence, super.key});

  final String label;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: Radii.pill,
        border: Border.all(color: colors.outline, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(
        Spacing.sm,
        Spacing.xs + 1,
        Spacing.md,
        Spacing.xs + 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Spacing.xs + 2),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onPrimaryContainer,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
