import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class ScholeraApp extends ConsumerWidget {
  const ScholeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Scholera',
      debugShowCheckedModeBanner: false,
      theme: buildScholeraTheme(),
      routerConfig: router,
    );
  }
}
