import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/scholera_scaffold.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/app_role.dart';

class StudentCoursesScreen extends ConsumerWidget {
  const StudentCoursesScreen({super.key});

  static const routeName = 'student-courses';
  static const routePath = '/student';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleThemeScope.forAppRole(
      role: AppRole.student,
      child: ScholeraScaffold.list(
        title: 'My courses',
        subtitle: 'Scholera · Student',
        showRoleBadge: true,
        actions: [
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
        children: const [
          EmptyState(
            icon: Icons.auto_stories_outlined,
            title: 'Your enrolled courses land next',
            message:
                'Announcements, modules, and your personal roadmap progress will open from here once the student flows are built.',
          ),
        ],
      ),
    );
  }
}
