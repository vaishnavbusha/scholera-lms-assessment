import 'package:flutter/material.dart';

import '../../../core/widgets/scholera_scaffold.dart';

class ProfessorCoursesScreen extends StatelessWidget {
  const ProfessorCoursesScreen({super.key});

  static const routeName = 'professor-courses';
  static const routePath = '/professor';

  @override
  Widget build(BuildContext context) {
    return ScholeraScaffold(
      title: 'Professor',
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
