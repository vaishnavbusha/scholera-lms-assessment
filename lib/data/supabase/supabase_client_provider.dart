import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseConfiguredProvider = Provider<bool>((ref) => false);

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final isConfigured = ref.watch(supabaseConfiguredProvider);

  if (!isConfigured) {
    throw StateError('Supabase is not configured.');
  }

  return Supabase.instance.client;
});
