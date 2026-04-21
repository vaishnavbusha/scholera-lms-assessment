import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/async_content.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../data/repositories/roadmap_repository.dart';
import '../../../auth/controllers/current_profile_provider.dart';
import '../../../roadmap/controllers/roadmap_providers.dart';
import '../../../roadmap/models/roadmap_module.dart';
import '../../../roadmap/views/widgets/roadmap_timeline.dart';

/// Student roadmap view — same timeline tree the professor sees, but the
/// coverage pill is read-only and the student gets their own tappable
/// "You:" picker that writes into `student_progress`.
class StudentRoadmapTab extends ConsumerWidget {
  const StudentRoadmapTab({required this.sectionId, super.key});

  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final key = (sectionId: sectionId, studentId: profile.id);
    final roadmap = ref.watch(studentRoadmapProvider(key));

    Future<void> changeStudentStatus(
      String itemId,
      ProgressStatus status,
    ) async {
      try {
        await ref.read(roadmapRepositoryProvider).upsertStudentStatus(
              studentId: profile.id,
              moduleItemId: itemId,
              status: status,
            );
        ref.invalidate(studentRoadmapProvider(key));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\u2019t save your progress: $e')),
        );
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(studentRoadmapProvider(key));
        await ref.read(studentRoadmapProvider(key).future);
      },
      child: AsyncContent<List<RoadmapModule>>(
        value: roadmap,
        loading: (_) => const LoadingSkeletonList(count: 3),
        onRetry: () => ref.invalidate(studentRoadmapProvider(key)),
        errorTitle: 'Couldn\u2019t load the roadmap',
        data: (modules) {
          if (modules.isEmpty) {
            return ListView(
              padding: Spacing.screenPadding,
              children: const [
                EmptyState(
                  icon: Icons.timeline_outlined,
                  title: 'Roadmap will populate from your professor',
                  message:
                      'Once your professor adds modules and items you\u2019ll see them here with topic chips and your own progress tracker.',
                ),
              ],
            );
          }
          return SingleChildScrollView(
            padding: Spacing.screenPadding,
            physics: const AlwaysScrollableScrollPhysics(),
            child: RoadmapTimeline(
              modules: modules,
              onStudentStatusChanged: changeStudentStatus,
            ),
          );
        },
      ),
    );
  }
}
