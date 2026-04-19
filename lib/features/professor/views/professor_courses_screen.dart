import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/scholera_scaffold.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/app_role.dart';

class ProfessorCoursesScreen extends ConsumerWidget {
  const ProfessorCoursesScreen({super.key});

  static const routeName = 'professor-courses';
  static const routePath = '/professor';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleThemeScope.forAppRole(
      role: AppRole.professor,
      child: ScholeraScaffold.list(
        title: 'My courses',
        subtitle: 'Scholera · Professor',
        showRoleBadge: true,
        actions: [
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
        children: const [
          EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Your course sections land next',
            message:
                'Announcements, modules, roadmap coverage, and extracted topics will open from here once the professor flows are built.',
          ),
        ],
      ),
    );
  }
}
