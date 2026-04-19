import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// AI-extracted topic label. Sits under a module item on the roadmap.
///
/// Uses the active role's primary color as a subtle left-edge accent so
/// admin/professor/student views can host the same chips and still feel
/// distinct from one another.
class TopicChip extends StatelessWidget {
  const TopicChip({required this.label, this.confidence, super.key});

  final String label;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: Radii.pill,
        border: Border(
          left: BorderSide(color: colors.primary, width: 2),
          top: BorderSide(color: colors.outline, width: 0.5),
          right: BorderSide(color: colors.outline, width: 0.5),
          bottom: BorderSide(color: colors.outline, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.xs + 1,
          Spacing.md,
          Spacing.xs + 1,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onPrimaryContainer,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
