import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/async_content.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/scholera_scaffold.dart';
import '../../auth/models/app_role.dart';
import '../controllers/admin_providers.dart';
import 'widgets/course_section_row.dart';
import 'widgets/professor_row.dart';

class ProfessorDetailScreen extends ConsumerWidget {
  const ProfessorDetailScreen({required this.professorId, super.key});

  static const routeName = 'admin-professor-detail';
  static const routePath = '/admin/professors/:id';

  final String professorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(professorDetailProvider(professorId));
    final loadedName = detail.value?.professor.displayName;

    return RoleThemeScope.forAppRole(
      role: AppRole.admin,
      child: ScholeraScaffold.custom(
        title: (loadedName == null || loadedName.isEmpty)
            ? 'Professor'
            : loadedName,
        subtitle: 'Professor',
        showRoleBadge: true,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(professorDetailProvider(professorId));
            await ref.read(professorDetailProvider(professorId).future);
          },
          child: AsyncContent(
            value: detail,
            errorTitle: 'Couldn\u2019t load professor',
            onRetry: () =>
                ref.invalidate(professorDetailProvider(professorId)),
            loading: (_) => const _ProfessorSkeleton(),
            data: (data) {
              final professor = data.professor;
              final sections = data.sections;

              return ListView(
                padding: Spacing.screenPadding,
                children: [
                  ProfessorRow(profile: professor),
                  if (professor.bio.isNotEmpty) ...[
                    const SizedBox(height: Spacing.lg),
                    Text(
                      professor.bio,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.xl),
                  _SectionHeader(
                    title: sections.length == 1
                        ? '1 course section'
                        : '${sections.length} course sections',
                    subtitle: 'Courses this professor teaches',
                  ),
                  const SizedBox(height: Spacing.md),
                  if (sections.isEmpty)
                    const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No course sections yet',
                      message:
                          'Once this professor is assigned to a section it will appear here.',
                      compact: true,
                    )
                  else
                    Column(
                      children: [
                        for (final (index, section) in sections.indexed) ...[
                          if (index > 0) const SizedBox(height: Spacing.md),
                          CourseSectionRow(section: section),
                        ],
                      ],
                    ),
                  const SizedBox(height: Spacing.xxl),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Matches the real layout footprint: professor row, bio bars, section
/// header, two course-section-row placeholders. Keeps skeleton → data
/// swap from jumping.
class _ProfessorSkeleton extends StatelessWidget {
  const _ProfessorSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rowDecoration = BoxDecoration(
      borderRadius: Radii.card,
      border: Border.all(color: colors.outline),
    );

    return ListView(
      padding: Spacing.screenPadding,
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: rowDecoration,
          child: Row(
            children: const [
              LoadingSkeletonBar(width: 44, height: 44, radius: 22),
              SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeletonBar(width: 160, height: 14),
                    SizedBox(height: Spacing.xs),
                    LoadingSkeletonBar(width: 220, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        const LoadingSkeletonBar(width: double.infinity, height: 14),
        const SizedBox(height: Spacing.xs),
        const LoadingSkeletonBar(width: 280, height: 14),
        const SizedBox(height: Spacing.xl),
        const LoadingSkeletonBar(width: 180, height: 20),
        const SizedBox(height: Spacing.xs),
        const LoadingSkeletonBar(width: 220, height: 12),
        const SizedBox(height: Spacing.md),
        for (int i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: rowDecoration,
            child: Row(
              children: const [
                LoadingSkeletonBar(width: 44, height: 44, radius: 8),
                SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoadingSkeletonBar(width: 220, height: 14),
                      SizedBox(height: Spacing.xs),
                      LoadingSkeletonBar(width: 160, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
