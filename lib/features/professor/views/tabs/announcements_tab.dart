import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/async_content.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../announcements/controllers/announcement_providers.dart';
import '../../../announcements/models/announcement.dart';
import '../sheets/create_announcement_sheet.dart';
import '../widgets/announcement_card.dart';

/// Professor's Announcements tab: list + new-announcement FAB.
class AnnouncementsTab extends ConsumerWidget {
  const AnnouncementsTab({required this.sectionId, super.key});

  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(sectionAnnouncementsProvider(sectionId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            CreateAnnouncementSheet.show(context, sectionId: sectionId),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: RefreshIndicator(
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
                        'Tap “New” to post the first announcement. Students will see it in the course detail.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: Spacing.screenPadding,
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: Spacing.md),
              itemBuilder: (_, i) => FadeSlideIn(
                index: i,
                child: AnnouncementCard(announcement: list[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}
