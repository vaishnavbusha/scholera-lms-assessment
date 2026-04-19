import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/scholera_scaffold.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/app_role.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  static const routeName = 'admin-home';
  static const routePath = '/admin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleThemeScope.forAppRole(
      role: AppRole.admin,
      child: ScholeraScaffold.list(
        title: 'Institution',
        subtitle: 'Scholera · Admin',
        showRoleBadge: true,
        actions: [
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
        children: const [
          EmptyState(
            icon: Icons.corporate_fare,
            title: 'Admin dashboard lands next',
            message:
                'Institution stats, departments, and professor assignments will render here once the admin data layer is wired up.',
          ),
        ],
      ),
    );
  }
}
