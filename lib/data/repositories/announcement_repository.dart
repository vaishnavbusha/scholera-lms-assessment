import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/announcements/models/announcement.dart';
import '../supabase/supabase_client_provider.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(ref.watch(supabaseClientProvider));
});

class AnnouncementRepository {
  const AnnouncementRepository(this._client);

  final SupabaseClient _client;

  /// Announcements for a section, newest first.
  Future<List<Announcement>> fetchForSection(String sectionId) async {
    final rows = await _client
        .from('announcements')
        .select()
        .eq('section_id', sectionId)
        .order('created_at', ascending: false);
    return rows.map(Announcement.fromJson).toList();
  }

  /// Single announcement. Used by the deep-link target.
  Future<Announcement> fetchById(String id) async {
    final row = await _client
        .from('announcements')
        .select()
        .eq('id', id)
        .single();
    return Announcement.fromJson(row);
  }

  /// Insert a new announcement and return the hydrated row. RLS guarantees
  /// the current user is the section's professor — the client just passes
  /// the ids through.
  Future<Announcement> create({
    required String sectionId,
    required String professorId,
    required String title,
    required String body,
  }) async {
    final row = await _client
        .from('announcements')
        .insert({
          'section_id': sectionId,
          'professor_id': professorId,
          'title': title,
          'body': body,
        })
        .select()
        .single();
    return Announcement.fromJson(row);
  }
}
