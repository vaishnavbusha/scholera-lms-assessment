import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/scholera_scaffold.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfessorCoursesScreen extends ConsumerWidget {
  const ProfessorCoursesScreen({super.key});

  static const routeName = 'professor-courses';
  static const routePath = '/professor';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScholeraScaffold(
      title: 'Professor',
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
          'Course sections, announcements, modules, and roadmap coverage controls will live here.',
        ),
      ],
    );
  }
}
