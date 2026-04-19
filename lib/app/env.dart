import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.current);

class AppEnv {
  const AppEnv({required this.supabaseUrl, required this.supabaseAnonKey});

  // Supabase is migrating the public client key from "anon" to "publishable".
  // Accept either name so a stock Supabase dashboard download drops in.
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static const current = AppEnv(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: _anonKey != '' ? _anonKey : _publishableKey,
  );

  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
