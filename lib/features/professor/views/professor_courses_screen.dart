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
import '../../courses/models/course_section.dart';
import '../../profile/views/profile_screen.dart';
import '../controllers/professor_providers.dart';
import 'professor_course_screen.dart';
import 'widgets/course_section_tile.dart';

class ProfessorCoursesScreen extends ConsumerWidget {
  const ProfessorCoursesScreen({super.key});

  static const routeName = 'professor-courses';
  static const routePath = '/professor';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(professorCourseSectionsProvider);

    return RoleThemeScope.forAppRole(
      role: AppRole.professor,
      child: ScholeraScaffold.custom(
        title: 'My courses',
        subtitle: 'Scholera \u00b7 Professor',
        showRoleBadge: true,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(ProfileScreen.routeName),
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(professorCourseSectionsProvider);
            await ref.read(professorCourseSectionsProvider.future);
          },
          child: AsyncContent<List<CourseSection>>(
            value: sections,
            loading: (_) => const LoadingSkeletonList(count: 3),
            onRetry: () => ref.invalidate(professorCourseSectionsProvider),
            errorTitle: 'Couldn\u2019t load your courses',
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'You don\u2019t have any course sections',
                  message:
                      'Course sections assigned to you by admin will appear here.',
                );
              }
              return ListView.separated(
                padding: Spacing.screenPadding,
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Spacing.md),
                itemBuilder: (_, index) {
                  final section = list[index];
                  return CourseSectionTile(
                    section: section,
                    onTap: () => context.pushNamed(
                      ProfessorCourseScreen.routeName,
                      pathParameters: {'sectionId': section.id},
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
