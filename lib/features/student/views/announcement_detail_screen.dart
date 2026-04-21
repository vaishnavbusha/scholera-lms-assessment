import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/async_content.dart';
import '../../../core/widgets/scholera_scaffold.dart';
import '../../../data/repositories/announcement_repository.dart';
import '../../announcements/models/announcement.dart';
import '../../auth/controllers/current_profile_provider.dart';

/// Full-screen announcement reader. The deep-link target — the URL scheme
/// `scholera://courses/{sectionId}/announcements/{id}` will eventually map
/// to this route.
class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({
    required this.sectionId,
    required this.announcementId,
    super.key,
  });

  static const routeName = 'student-announcement-detail';
  static const routePath = 'announcements/:announcementId';

  final String sectionId;
  final String announcementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.watch(_announcementByIdProvider(announcementId));
    final role = ref.watch(currentProfileProvider).role;

    return RoleThemeScope.forAppRole(
      role: role,
      child: AsyncContent<Announcement>(
        value: future,
        errorTitle: 'Couldn\u2019t load that announcement',
        onRetry: () => ref.invalidate(_announcementByIdProvider(announcementId)),
        data: (announcement) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;

          return ScholeraScaffold.list(
            title: 'Announcement',
            subtitle: _formatTimestamp(announcement.createdAt),
            showRoleBadge: true,
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
                    'Posted ${_formatTimestamp(announcement.createdAt)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(announcement.title, style: theme.textTheme.headlineLarge),
              const SizedBox(height: Spacing.lg),
              Text(
                announcement.body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: colors.onSurface,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    return DateFormat('MMM d, y \u00b7 h:mm a').format(local);
  }
}

final _announcementByIdProvider = FutureProvider.autoDispose
    .family<Announcement, String>((ref, id) {
  return ref.watch(announcementRepositoryProvider).fetchById(id);
});
