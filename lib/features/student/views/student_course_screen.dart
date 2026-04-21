import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/async_content.dart';
import '../../auth/models/app_role.dart';
import '../../courses/models/course_section.dart';
import '../controllers/student_providers.dart';
import 'tabs/student_announcements_tab.dart';
import 'tabs/student_modules_tab.dart';
import 'tabs/student_roadmap_tab.dart';

/// Student's course detail shell. Same three tabs as the professor shell,
/// but read-only content (Announcements / Modules) and a student-progress
/// picker on the Roadmap instead of the coverage picker.
class StudentCourseScreen extends ConsumerStatefulWidget {
  const StudentCourseScreen({required this.sectionId, super.key});

  static const routeName = 'student-course';
  static const routePath = 'courses/:sectionId';

  final String sectionId;

  @override
  ConsumerState<StudentCourseScreen> createState() =>
      _StudentCourseScreenState();
}

class _StudentCourseScreenState extends ConsumerState<StudentCourseScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(studentCourseSectionProvider(widget.sectionId));

    return RoleThemeScope.forAppRole(
      role: AppRole.student,
      child: AsyncContent<CourseSection>(
        value: section,
        errorTitle: 'Couldn\u2019t load this course',
        onRetry: () => ref.invalidate(
          studentCourseSectionProvider(widget.sectionId),
        ),
        data: (section) {
          final course = section.course;
          final title = course?.title ?? 'Course';
          final subtitle = [
            if (course?.code != null && course!.code.isNotEmpty) course.code,
            section.term,
            'Section ${section.sectionCode}',
          ].join(' \u00b7 ');

          return Scaffold(
            appBar: _StudentCourseAppBar(
              title: title,
              subtitle: subtitle,
              tabController: _tabController,
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                StudentAnnouncementsTab(sectionId: widget.sectionId),
                StudentModulesTab(sectionId: widget.sectionId),
                StudentRoadmapTab(sectionId: widget.sectionId),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StudentCourseAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _StudentCourseAppBar({
    required this.title,
    required this.subtitle,
    required this.tabController,
  });

  final String title;
  final String subtitle;
  final TabController tabController;

  @override
  Size get preferredSize => const Size.fromHeight(64 + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      titleSpacing: Spacing.lg,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.appBarTheme.titleTextStyle),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: tabController,
        labelColor: colors.primary,
        unselectedLabelColor: colors.onSurfaceVariant,
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2.5,
        labelStyle: theme.textTheme.labelLarge,
        unselectedLabelStyle: theme.textTheme.labelLarge,
        tabs: const [
          Tab(text: 'Announcements'),
          Tab(text: 'Modules'),
          Tab(text: 'Roadmap'),
        ],
      ),
    );
  }
}
