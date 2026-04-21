import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/async_content.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../announcements/controllers/announcement_providers.dart';
import '../../../announcements/models/announcement.dart';
import '../../../professor/views/widgets/announcement_card.dart';
import '../announcement_detail_screen.dart';

/// Student-side announcements tab. Read-only, tap-to-open-detail.
class StudentAnnouncementsTab extends ConsumerWidget {
  const StudentAnnouncementsTab({required this.sectionId, super.key});

  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(sectionAnnouncementsProvider(sectionId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(sectionAnnouncementsProvider(sectionId));
        await ref.read(sectionAnnouncementsProvider(sectionId).future);
      },
      child: AsyncContent<List<Announcement>>(
        value: announcements,
        loading: (_) => const LoadingSkeletonList(count: 3),
        onRetry: () =>
            ref.invalidate(sectionAnnouncementsProvider(sectionId)),
        errorTitle: 'Couldn\u2019t load announcements',
        data: (list) {
          if (list.isEmpty) {
            return ListView(
              padding: Spacing.screenPadding,
              children: const [
                EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'No announcements yet',
                  message:
                      'When your professor posts an announcement it will appear here.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: Spacing.screenPadding,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
            itemBuilder: (_, i) {
              final announcement = list[i];
              return AnnouncementCard(
                announcement: announcement,
                onTap: () => context.pushNamed(
                  AnnouncementDetailScreen.routeName,
                  pathParameters: {
                    'sectionId': sectionId,
                    'announcementId': announcement.id,
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
