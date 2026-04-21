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
import '../../profile/views/profile_screen.dart';
import '../controllers/admin_providers.dart';
import '../models/department_with_professors.dart';
import '../models/institution_stats.dart';
import 'department_detail_screen.dart';
import 'widgets/department_row.dart';
import 'widgets/stat_card.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  static const routeName = 'admin-home';
  static const routePath = '/admin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(institutionStatsProvider);
    final departments = ref.watch(departmentsListProvider);

    return RoleThemeScope.forAppRole(
      role: AppRole.admin,
      child: ScholeraScaffold.custom(
        title: 'Institution',
        subtitle: 'Scholera · Admin',
        showRoleBadge: true,
        onRoleBadgeTap: () => context.pushNamed(ProfileScreen.routeName),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(institutionStatsProvider);
            ref.invalidate(departmentsListProvider);
            await Future.wait([
              ref.read(institutionStatsProvider.future),
              ref.read(departmentsListProvider.future),
            ]);
          },
          child: ListView(
            padding: Spacing.screenPadding,
            children: [
              AsyncContent<InstitutionStats>(
                value: stats,
                loading: (_) => const _StatsSkeleton(),
                onRetry: () => ref.invalidate(institutionStatsProvider),
                data: (stats) => _StatsGrid(stats: stats),
                errorTitle: 'Couldn\u2019t load institution stats',
              ),
              const SizedBox(height: Spacing.xxl),
              _SectionHeader(
                title: 'Departments',
                subtitle: 'Tap to view each department\u2019s professors',
              ),
              const SizedBox(height: Spacing.md),
              AsyncContent<List<DepartmentWithProfessors>>(
                value: departments,
                loading: (_) => const LoadingSkeletonList(count: 3),
                onRetry: () => ref.invalidate(departmentsListProvider),
                errorTitle: 'Couldn\u2019t load departments',
                data: (list) {
                  if (list.isEmpty) {
                    return const EmptyState(
                      icon: Icons.domain_outlined,
                      title: 'No departments yet',
                      message:
                          'Once departments are added to the institution they will appear here.',
                      compact: true,
                    );
                  }
                  return Column(
                    children: [
                      for (final (index, dept) in list.indexed) ...[
                        if (index > 0) const SizedBox(height: Spacing.md),
                        DepartmentRow(
                          data: dept,
                          onTap: () => context.pushNamed(
                            DepartmentDetailScreen.routeName,
                            pathParameters: {'id': dept.department.id},
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final InstitutionStats stats;

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(
        label: 'Students',
        value: stats.studentCount,
        icon: Icons.school_outlined,
      ),
      StatCard(
        label: 'Professors',
        value: stats.professorCount,
        icon: Icons.person_outline,
      ),
      StatCard(
        label: 'Courses',
        value: stats.courseCount,
        icon: Icons.menu_book_outlined,
      ),
      StatCard(
        label: 'Departments',
        value: stats.departmentCount,
        icon: Icons.domain_outlined,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: Spacing.md,
      mainAxisSpacing: Spacing.md,
      childAspectRatio: 1.35,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: cards,
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: Spacing.md,
      mainAxisSpacing: Spacing.md,
      childAspectRatio: 1.35,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: List.generate(
        4,
        (_) => Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: Radii.card,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              LoadingSkeletonBar(width: 36, height: 36, radius: 8),
              Spacer(),
              LoadingSkeletonBar(width: 60, height: 28),
              SizedBox(height: Spacing.xs),
              LoadingSkeletonBar(width: 80, height: 12),
            ],
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
