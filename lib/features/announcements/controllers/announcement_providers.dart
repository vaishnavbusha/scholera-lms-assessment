import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/announcement_repository.dart';
import '../../../data/supabase/supabase_client_provider.dart';
import '../models/announcement.dart';

/// Announcements for a specific section. Live: yields the initial list, then
/// refetches and re-emits whenever an `announcements` row for this section
/// changes (insert, update, delete) via Supabase Realtime. The full list is
/// re-fetched per change rather than diffed locally — keeps ordering and
/// joins simple, and the channel only fires on actual writes anyway.
final sectionAnnouncementsProvider = StreamProvider.autoDispose
    .family<List<Announcement>, String>((ref, sectionId) {
  final repo = ref.watch(announcementRepositoryProvider);
  final client = ref.watch(supabaseClientProvider);
  final controller = StreamController<List<Announcement>>();

  Future<void> emitFresh() async {
    if (controller.isClosed) return;
    try {
      final list = await repo.fetchForSection(sectionId);
      if (!controller.isClosed) controller.add(list);
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    }
  }

  final channel = client
      .channel('section-announcements-$sectionId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'announcements',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'section_id',
          value: sectionId,
        ),
        callback: (_) => emitFresh(),
      )
      .subscribe();

  // Initial load.
  emitFresh();

  ref.onDispose(() async {
    await client.removeChannel(channel);
    await controller.close();
  });

  return controller.stream;
});
