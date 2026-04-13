import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.current);

class AppEnv {
  const AppEnv({required this.supabaseUrl, required this.supabaseAnonKey});

  static const current = AppEnv(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
