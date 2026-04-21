import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/async_content.dart';
import '../../auth/models/app_role.dart';
import '../../courses/models/course_section.dart';
import '../controllers/professor_providers.dart';
import 'tabs/announcements_tab.dart';
import 'tabs/modules_tab.dart';
import 'tabs/professor_roadmap_tab.dart';

/// Professor's course management shell. Three tabs (Announcements, Modules,
/// Roadmap) mirror the rubric's course management structure. Each tab owns
/// its own state; this widget only orchestrates the shell + tabs.
class ProfessorCourseScreen extends ConsumerStatefulWidget {
  const ProfessorCourseScreen({required this.sectionId, super.key});

  static const routeName = 'professor-course';
  static const routePath = 'courses/:sectionId';

  final String sectionId;

  @override
  ConsumerState<ProfessorCourseScreen> createState() =>
      _ProfessorCourseScreenState();
}

class _ProfessorCourseScreenState extends ConsumerState<ProfessorCourseScreen>
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
    final section = ref.watch(
      professorCourseSectionProvider(widget.sectionId),
    );

    return RoleThemeScope.forAppRole(
      role: AppRole.professor,
      child: AsyncContent<CourseSection>(
        value: section,
        errorTitle: 'Couldn\u2019t load this course',
        onRetry: () => ref.invalidate(
          professorCourseSectionProvider(widget.sectionId),
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
            appBar: _CourseAppBar(
              title: title,
              subtitle: subtitle,
              tabController: _tabController,
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                AnnouncementsTab(sectionId: widget.sectionId),
                ModulesTab(sectionId: widget.sectionId),
                ProfessorRoadmapTab(sectionId: widget.sectionId),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CourseAppBar({
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

