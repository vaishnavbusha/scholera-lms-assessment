import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/errors/friendly_error.dart';
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
class StudentRoadmapTab extends ConsumerStatefulWidget {
  const StudentRoadmapTab({required this.sectionId, super.key});

  final String sectionId;

  @override
  ConsumerState<StudentRoadmapTab> createState() => _StudentRoadmapTabState();
}

class _StudentRoadmapTabState extends ConsumerState<StudentRoadmapTab> {
  /// Optimistic overrides for the student's own progress, keyed by
  /// moduleItemId. Cleared on pull-to-refresh.
  final Map<String, ProgressStatus> _overrides = {};

  Future<void> _changeStatus(
    StudentRoadmapKey key,
    String itemId,
    ProgressStatus status,
  ) async {
    final previous = _overrides[itemId];
    setState(() => _overrides[itemId] = status);

    try {
      await ref.read(roadmapRepositoryProvider).upsertStudentStatus(
            studentId: key.studentId,
            moduleItemId: itemId,
            status: status,
          );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (previous == null) {
          _overrides.remove(itemId);
        } else {
          _overrides[itemId] = previous;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Couldn\u2019t save your progress: ${friendlyErrorMessage(e)}',
          ),
        ),
      );
    }
  }

  Future<void> _refresh(StudentRoadmapKey key) async {
    setState(_overrides.clear);
    ref.invalidate(studentRoadmapProvider(key));
    await ref.read(studentRoadmapProvider(key).future);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final key = (sectionId: widget.sectionId, studentId: profile.id);
    final roadmap = ref.watch(studentRoadmapProvider(key));

    return RefreshIndicator(
      onRefresh: () => _refresh(key),
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
          final view = _applyOverrides(modules);
          return SingleChildScrollView(
            padding: Spacing.screenPadding,
            physics: const AlwaysScrollableScrollPhysics(),
            child: RoadmapTimeline(
              modules: view,
              onStudentStatusChanged: (itemId, status) =>
                  _changeStatus(key, itemId, status),
            ),
          );
        },
      ),
    );
  }

  List<RoadmapModule> _applyOverrides(List<RoadmapModule> modules) {
    if (_overrides.isEmpty) return modules;
    return [
      for (final module in modules)
        RoadmapModule(
          id: module.id,
          sectionId: module.sectionId,
          title: module.title,
          position: module.position,
          items: [
            for (final item in module.items)
              _overrides.containsKey(item.id)
                  ? item.copyWith(studentStatus: _overrides[item.id])
                  : item,
          ],
        ),
    ];
  }
}
