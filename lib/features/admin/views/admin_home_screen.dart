import 'package:flutter/material.dart';

import '../../../core/widgets/scholera_scaffold.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const routeName = 'admin-home';
  static const routePath = '/admin';

  @override
  Widget build(BuildContext context) {
    return ScholeraScaffold(
      title: 'Admin',
      children: [
        Text(
          'Institution overview',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Departments, professors, courses, and student counts will load from Supabase.',
        ),
      ],
    );
  }
}
