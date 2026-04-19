import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';

/// Stat card used on the admin dashboard. One big number, a label, a small
/// icon badge tinted in the active role color.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final int value;
  final IconData icon;

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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: Radii.button,
            ),
            child: Icon(icon, size: 18, color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            '$value',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
