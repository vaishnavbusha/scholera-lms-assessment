import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/tokens.dart';
import '../../../announcements/models/announcement.dart';

/// Announcement list card. Read-only display — tapping opens the full text
/// if [onTap] is provided (student flow will want this; professor flow
/// doesn't need the detail screen yet).
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    required this.announcement,
    this.onTap,
    super.key,
  });

  final Announcement announcement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final content = Container(
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
              Icon(
                Icons.campaign_outlined,
                color: colors.primary,
                size: 16,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                _formatTimestamp(announcement.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(announcement.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: Spacing.xs),
          Text(
            announcement.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: Radii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.card,
        child: content,
      ),
    );
  }

  static String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final today = DateTime.now();
    if (local.year == today.year &&
        local.month == today.month &&
        local.day == today.day) {
      return 'Today \u00b7 ${DateFormat.jm().format(local)}';
    }
    return DateFormat('MMM d, y \u00b7 h:mm a').format(local);
  }
}
