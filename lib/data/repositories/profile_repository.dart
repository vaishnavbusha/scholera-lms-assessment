import 'dart:typed_data';

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

  static const String _avatarBucket = 'avatars';

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

  /// Updates display name and bio for the given profile id.
  /// RLS ensures only the owning user can call this successfully.
  Future<AppProfile> updateProfile({
    required String id,
    required String displayName,
    required String bio,
  }) async {
    final row = await _client
        .from('profiles')
        .update({
          'display_name': displayName,
          'bio': bio,
        })
        .eq('id', id)
        .select()
        .single();
    return AppProfile.fromJson(row);
  }

  /// Uploads a new avatar for [userId] to `avatars/{userId}/avatar_{ts}.{ext}`.
  /// Writes the public URL back to the profile's `avatar_url` and returns
  /// the hydrated [AppProfile].
  ///
  /// A timestamp in the filename side-steps Supabase's CDN caching — the new
  /// URL differs from any previous one, so updated avatars appear immediately.
  Future<AppProfile> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = _sanitizeFileName(fileName);
    final objectPath = '$userId/${timestamp}_$safeName';

    await _client.storage
        .from(_avatarBucket)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentTypeFor(safeName),
            upsert: false,
          ),
        );

    final publicUrl = _client.storage
        .from(_avatarBucket)
        .getPublicUrl(objectPath);

    final row = await _client
        .from('profiles')
        .update({'avatar_url': publicUrl})
        .eq('id', userId)
        .select()
        .single();
    return AppProfile.fromJson(row);
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }

  String _contentTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'application/octet-stream';
  }
}
