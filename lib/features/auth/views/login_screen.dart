import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/scholera_scaffold.dart';
import '../../admin/views/admin_home_screen.dart';
import '../../professor/views/professor_courses_screen.dart';
import '../../student/views/student_courses_screen.dart';
import '../controllers/auth_controller.dart';
import '../models/app_role.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const routeName = 'login';
  static const routePath = '/login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedPreviewRoleProvider);

    return ScholeraScaffold(
      title: 'Scholera',
      children: [
        Text(
          'Sign in',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Supabase authentication will route each user into the right workspace.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: selectedRole == null
              ? null
              : () => _openPreviewRole(context, selectedRole),
          child: const Text('Continue'),
        ),
        const SizedBox(height: 28),
        Text(
          'Preview role shell',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppRole.values.map((role) {
            return ChoiceChip(
              label: Text(role.label),
              selected: selectedRole == role,
              onSelected: (_) {
                ref.read(selectedPreviewRoleProvider.notifier).select(role);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _openPreviewRole(BuildContext context, AppRole role) {
    switch (role) {
      case AppRole.admin:
        context.goNamed(AdminHomeScreen.routeName);
      case AppRole.professor:
        context.goNamed(ProfessorCoursesScreen.routeName);
      case AppRole.student:
        context.goNamed(StudentCoursesScreen.routeName);
    }
  }
}
