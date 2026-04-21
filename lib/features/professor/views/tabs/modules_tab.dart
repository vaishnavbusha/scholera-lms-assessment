import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/async_content.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../modules/controllers/module_providers.dart';
import '../../../modules/models/course_module.dart';
import '../sheets/create_module_item_sheet.dart';
import '../sheets/create_module_sheet.dart';
import '../widgets/module_card.dart';

/// Professor's Modules tab: list of modules (with items inside) + a New
/// module FAB. Each module card has its own Add item button.
class ModulesTab extends ConsumerWidget {
  const ModulesTab({required this.sectionId, super.key});

  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(sectionModulesProvider(sectionId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            CreateModuleSheet.show(context, sectionId: sectionId),
        icon: const Icon(Icons.add),
        label: const Text('New module'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sectionModulesProvider(sectionId));
          await ref.read(sectionModulesProvider(sectionId).future);
        },
        child: AsyncContent<List<CourseModule>>(
          value: modules,
          loading: (_) => const LoadingSkeletonList(count: 3),
          onRetry: () => ref.invalidate(sectionModulesProvider(sectionId)),
          errorTitle: 'Couldn\u2019t load modules',
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                padding: Spacing.screenPadding,
                children: const [
                  EmptyState(
                    icon: Icons.folder_outlined,
                    title: 'No modules yet',
                    message:
                        'Tap “New module” to create the first one. You can add link, note, or file items inside it after.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: Spacing.screenPadding,
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: Spacing.md),
              itemBuilder: (_, i) {
                final module = list[i];
                return ModuleCard(
                  module: module,
                  onAddItem: () => CreateModuleItemSheet.show(
                    context,
                    moduleId: module.id,
                    sectionId: sectionId,
                    moduleTitle: module.title,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
