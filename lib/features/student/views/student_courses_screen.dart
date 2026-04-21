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
import '../../professor/views/widgets/course_section_tile.dart';
import '../controllers/student_providers.dart';
import 'student_course_screen.dart';

class StudentCoursesScreen extends ConsumerWidget {
  const StudentCoursesScreen({super.key});

  static const routeName = 'student-courses';
  static const routePath = '/student';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(studentCourseSectionsProvider);

    return RoleThemeScope.forAppRole(
      role: AppRole.student,
      child: ScholeraScaffold.custom(
        title: 'My courses',
        subtitle: 'Scholera \u00b7 Student',
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
            ref.invalidate(studentCourseSectionsProvider);
            await ref.read(studentCourseSectionsProvider.future);
          },
          child: AsyncContent<List<CourseSection>>(
            value: sections,
            loading: (_) => const LoadingSkeletonList(count: 3),
            onRetry: () => ref.invalidate(studentCourseSectionsProvider),
            errorTitle: 'Couldn\u2019t load your courses',
            data: (list) {
              if (list.isEmpty) {
                return ListView(
                  padding: Spacing.screenPadding,
                  children: const [
                    EmptyState(
                      icon: Icons.auto_stories_outlined,
                      title: 'You\u2019re not enrolled in any courses',
                      message:
                          'Your enrollments will show up here once an admin adds you to a section.',
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
                  final section = list[i];
                  return CourseSectionTile(
                    section: section,
                    onTap: () => context.pushNamed(
                      StudentCourseScreen.routeName,
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
