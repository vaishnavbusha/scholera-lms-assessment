import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/async_content.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../data/repositories/roadmap_repository.dart';
import '../../../roadmap/controllers/roadmap_providers.dart';
import '../../../roadmap/models/roadmap_module.dart';
import '../../../roadmap/views/widgets/roadmap_timeline.dart';

/// Professor roadmap view — timeline tree: one spine running through the
/// whole section, module nodes branching off, items hanging below each
/// module, each item showing extracted topics and a tappable coverage picker.
class ProfessorRoadmapTab extends ConsumerWidget {
  const ProfessorRoadmapTab({required this.sectionId, super.key});

  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roadmap = ref.watch(professorRoadmapProvider(sectionId));

    Future<void> changeStatus(String itemId, ProgressStatus status) async {
      try {
        await ref
            .read(roadmapRepositoryProvider)
            .updateProfessorStatus(moduleItemId: itemId, status: status);
        ref.invalidate(professorRoadmapProvider(sectionId));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\u2019t update coverage: $e')),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(professorRoadmapProvider(sectionId));
          await ref.read(professorRoadmapProvider(sectionId).future);
        },
        child: AsyncContent<List<RoadmapModule>>(
          value: roadmap,
          loading: (_) => const LoadingSkeletonList(count: 3),
          onRetry: () =>
              ref.invalidate(professorRoadmapProvider(sectionId)),
          errorTitle: 'Couldn\u2019t load the roadmap',
          data: (modules) {
            if (modules.isEmpty) {
              return ListView(
                padding: Spacing.screenPadding,
                children: const [
                  EmptyState(
                    icon: Icons.timeline_outlined,
                    title: 'Roadmap will populate from your modules',
                    message:
                        'The roadmap is built automatically from modules and items. Create a module and add an item to see this view fill in.',
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              padding: Spacing.screenPadding,
              physics: const AlwaysScrollableScrollPhysics(),
              child: RoadmapTimeline(
                modules: modules,
                onProfessorStatusChanged: changeStatus,
              ),
            );
          },
        ),
      ),
    );
  }
}
