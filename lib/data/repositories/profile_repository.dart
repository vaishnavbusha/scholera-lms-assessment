import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/profile/models/app_profile.dart';
import '../supabase/supabase_client_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

class ProfileRepository {
  const ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<AppProfile> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw const AuthException('No authenticated user found.');
    }

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return AppProfile.fromJson(response);
  }
}
