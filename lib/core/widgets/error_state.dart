import 'package:flutter/material.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/tokens.dart';

/// Friendly error state. Calm phrasing — errors happen, we don't shout.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.compact = false,
    super.key,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: compact ? Spacing.xl : Spacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Palette.errorContainer,
              borderRadius: Radii.pill,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Palette.error,
              size: 24,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          if (message != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              _shorten(message!),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: Spacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(retryLabel),
            ),
          ],
        ],
      ),
    );
  }

  static String _shorten(String text) {
    const limit = 220;
    if (text.length <= limit) return text;
    return '${text.substring(0, limit - 1)}…';
  }
}
