import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/scholera_scaffold.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  static const routeName = 'admin-home';
  static const routePath = '/admin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScholeraScaffold(
      title: 'Admin',
      actions: [
        TextButton(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          child: const Text('Sign out'),
        ),
      ],
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
