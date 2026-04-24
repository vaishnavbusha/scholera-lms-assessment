import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/async_content.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/scholera_scaffold.dart';
import '../../auth/models/app_role.dart';
import '../controllers/admin_providers.dart';
import 'professor_detail_screen.dart';
import 'widgets/professor_row.dart';

class DepartmentDetailScreen extends ConsumerWidget {
  const DepartmentDetailScreen({required this.departmentId, super.key});

  static const routeName = 'admin-department-detail';
  static const routePath = '/admin/departments/:id';

  final String departmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(departmentDetailProvider(departmentId));

    // Keep the scaffold stable through loading/data/error so the app bar
    // doesn't pop in when data arrives. The body swaps inside a fading
    // AsyncContent so the skeleton → data transition is smooth.
    return RoleThemeScope.forAppRole(
      role: AppRole.admin,
      child: ScholeraScaffold.custom(
        title: detail.value?.department.name ?? 'Department',
        subtitle: 'Department',
        showRoleBadge: true,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(departmentDetailProvider(departmentId));
            await ref.read(departmentDetailProvider(departmentId).future);
          },
          child: AsyncContent(
            value: detail,
            errorTitle: 'Couldn\u2019t load department',
            onRetry: () =>
                ref.invalidate(departmentDetailProvider(departmentId)),
            loading: (_) => const _DepartmentSkeleton(),
            data: (data) {
              final dept = data.department;
              final professors = data.professors;

              return ListView(
                padding: Spacing.screenPadding,
                children: [
                  if (dept.description != null &&
                      dept.description!.isNotEmpty) ...[
                    Text(
                      dept.description!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                  ],
                  _SectionHeader(
                    title: professors.length == 1
                        ? '1 professor'
                        : '${professors.length} professors',
                  ),
                  const SizedBox(height: Spacing.md),
                  if (professors.isEmpty)
                    const EmptyState(
                      icon: Icons.person_outline,
                      title: 'No professors assigned',
                      message:
                          'Once professors are assigned to this department they will appear here.',
                      compact: true,
                    )
                  else
                    Column(
                      children: [
                        for (final (index, professor) in professors.indexed) ...[
                          if (index > 0) const SizedBox(height: Spacing.md),
                          ProfessorRow(
                            profile: professor,
                            onTap: () => context.pushNamed(
                              ProfessorDetailScreen.routeName,
                              pathParameters: {'id': professor.id},
                            ),
                          ),
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
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

/// Matches the real layout's footprint: description bars, section header,
/// three professor-row-shaped cards. Keeps skeleton → data swap from
/// visually jumping.
class _DepartmentSkeleton extends StatelessWidget {
  const _DepartmentSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Spacing.screenPadding,
      children: const [
        LoadingSkeletonBar(width: double.infinity, height: 14),
        SizedBox(height: Spacing.xs),
        LoadingSkeletonBar(width: 220, height: 14),
        SizedBox(height: Spacing.xl),
        LoadingSkeletonBar(width: 140, height: 20),
        SizedBox(height: Spacing.md),
        _ProfessorRowSkeleton(),
        SizedBox(height: Spacing.md),
        _ProfessorRowSkeleton(),
        SizedBox(height: Spacing.md),
        _ProfessorRowSkeleton(),
      ],
    );
  }
}

class _ProfessorRowSkeleton extends StatelessWidget {
  const _ProfessorRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        borderRadius: Radii.card,
        border: Border.all(color: colors.outline),
      ),
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
    );
  }
}
