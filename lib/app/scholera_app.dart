import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/role_theme.dart';

class ScholeraApp extends ConsumerWidget {
  const ScholeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // The default theme is the neutral (pre-auth) palette. Role shells wrap
    // their subtrees in [RoleThemeScope] to apply the admin/professor/
    // student accent.
    return MaterialApp.router(
      title: 'Scholera',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(RoleTheme.neutral),
      routerConfig: router,
    );
  }
}
