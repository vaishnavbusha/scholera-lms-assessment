import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Reusable "there's nothing here yet" state.
///
/// Warm phrasing, serif title, optional call-to-action. Designed to fit
/// inside lists (slivers wrap it) or full screens.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.message,
    this.icon,
    this.action,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: compact ? Spacing.xl : Spacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: Radii.pill,
              ),
              child: Icon(icon, color: colors.onPrimaryContainer, size: 24),
            ),
            const SizedBox(height: Spacing.lg),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          if (message != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: Spacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
