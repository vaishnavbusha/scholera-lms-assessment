import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/errors/friendly_error.dart';
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
class ProfessorRoadmapTab extends ConsumerStatefulWidget {
  const ProfessorRoadmapTab({required this.sectionId, super.key});

  final String sectionId;

  @override
  ConsumerState<ProfessorRoadmapTab> createState() =>
      _ProfessorRoadmapTabState();
}

class _ProfessorRoadmapTabState extends ConsumerState<ProfessorRoadmapTab> {
  /// Optimistic overrides keyed by moduleItemId. Applied on top of the fetched
  /// data so the picker feels instant — the API call completes in the
  /// background. Cleared on pull-to-refresh.
  final Map<String, ProgressStatus> _overrides = {};

  Future<void> _changeStatus(String itemId, ProgressStatus status) async {
    final previous = _overrides[itemId];
    setState(() => _overrides[itemId] = status);

    try {
      await ref
          .read(roadmapRepositoryProvider)
          .updateProfessorStatus(moduleItemId: itemId, status: status);
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
            'Couldn\u2019t update coverage: ${friendlyErrorMessage(e)}',
          ),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    setState(_overrides.clear);
    ref.invalidate(professorRoadmapProvider(widget.sectionId));
    await ref.read(professorRoadmapProvider(widget.sectionId).future);
  }

  @override
  Widget build(BuildContext context) {
    final roadmap = ref.watch(professorRoadmapProvider(widget.sectionId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AsyncContent<List<RoadmapModule>>(
          value: roadmap,
          loading: (_) => const LoadingSkeletonList(count: 3),
          onRetry: () =>
              ref.invalidate(professorRoadmapProvider(widget.sectionId)),
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
            final view = _applyOverrides(modules);
            return SingleChildScrollView(
              padding: Spacing.screenPadding,
              physics: const AlwaysScrollableScrollPhysics(),
              child: RoadmapTimeline(
                modules: view,
                onProfessorStatusChanged: _changeStatus,
              ),
            );
          },
        ),
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
                  ? item.copyWith(professorStatus: _overrides[item.id])
                  : item,
          ],
        ),
    ];
  }
}
