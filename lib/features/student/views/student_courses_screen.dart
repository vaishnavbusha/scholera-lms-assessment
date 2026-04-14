import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/scholera_scaffold.dart';
import '../../auth/controllers/auth_controller.dart';

class StudentCoursesScreen extends ConsumerWidget {
  const StudentCoursesScreen({super.key});

  static const routeName = 'student-courses';
  static const routePath = '/student';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScholeraScaffold(
      title: 'Student',
      actions: [
        TextButton(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          child: const Text('Sign out'),
        ),
      ],
      children: [
        Text(
          'My courses',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enrolled courses, read-only modules, announcements, and personal roadmap progress will live here.',
        ),
      ],
    );
  }
}
