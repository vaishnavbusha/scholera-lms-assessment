import 'package:flutter/material.dart';

import '../../../core/widgets/scholera_scaffold.dart';

class StudentCoursesScreen extends StatelessWidget {
  const StudentCoursesScreen({super.key});

  static const routeName = 'student-courses';
  static const routePath = '/student';

  @override
  Widget build(BuildContext context) {
    return ScholeraScaffold(
      title: 'Student',
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
