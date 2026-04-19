import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/async_content.dart';
import '../../../core/widgets/empty_state.dart';
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

    return RoleThemeScope.forAppRole(
      role: AppRole.admin,
      child: AsyncContent(
        value: detail,
        errorTitle: 'Couldn\u2019t load department',
        onRetry: () => ref.invalidate(departmentDetailProvider(departmentId)),
        data: (data) {
          final dept = data.department;
          final professors = data.professors;

          return ScholeraScaffold.custom(
            title: dept.name,
            subtitle: 'Department',
            showRoleBadge: true,
            body: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(departmentDetailProvider(departmentId));
                await ref.read(
                  departmentDetailProvider(departmentId).future,
                );
              },
              child: ListView(
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
              ),
            ),
          );
        },
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
