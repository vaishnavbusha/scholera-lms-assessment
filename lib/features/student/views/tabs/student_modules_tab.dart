import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/async_content.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../modules/controllers/module_providers.dart';
import '../../../modules/models/course_module.dart';
import '../../../professor/views/widgets/module_item_row.dart';

/// Student-side modules tab. Same module cards the professor sees, minus
/// the "Add item" button. Items remain tappable — the ModuleItemRow
/// opens links / notes / files for anyone who can render it.
class StudentModulesTab extends ConsumerWidget {
  const StudentModulesTab({required this.sectionId, super.key});

  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(sectionModulesProvider(sectionId));

    return RefreshIndicator(
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
                      'Your professor hasn\u2019t added any modules to this course. Pull to refresh later.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: Spacing.screenPadding,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
            itemBuilder: (_, i) => _StudentModuleCard(module: list[i]),
          );
        },
      ),
    );
  }
}

class _StudentModuleCard extends StatelessWidget {
  const _StudentModuleCard({required this.module});

  final CourseModule module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: Radii.button,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${module.position + 1}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  module.title,
                  style: theme.textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (module.items.isEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text(
              'No items yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const SizedBox(height: Spacing.sm),
            const Divider(height: 1),
            for (final item in module.items) ModuleItemRow(item: item),
          ],
        ],
      ),
    );
  }
}
