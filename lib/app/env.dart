import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.current);

class AppEnv {
  const AppEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.geminiApiKey,
  });

  // Supabase is migrating the public client key from "anon" to "publishable".
  // Accept either name so a stock Supabase dashboard download drops in.
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static const current = AppEnv(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: _anonKey != '' ? _anonKey : _publishableKey,
    geminiApiKey: String.fromEnvironment('GEMINI_API_KEY'),
  );

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String geminiApiKey;

  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Lecture insights are an opt-in stretch-goal feature — enabled only when
  /// the launcher passes a `GEMINI_API_KEY` dart-define. When unset, the UI
  /// falls back to file metadata.
  bool get hasGeminiConfig => geminiApiKey.isNotEmpty;
}
