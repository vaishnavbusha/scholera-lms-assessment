import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/env.dart';
import 'app/scholera_app.dart';
import 'data/supabase/supabase_client_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = AppEnv.current;
  final isSupabaseConfigured = env.hasSupabaseConfig;

  if (isSupabaseConfigured) {
    await Supabase.initialize(
      url: env.supabaseUrl,
      anonKey: env.supabaseAnonKey,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        supabaseConfiguredProvider.overrideWithValue(isSupabaseConfigured),
      ],
      child: const ScholeraApp(),
    ),
  );
}
