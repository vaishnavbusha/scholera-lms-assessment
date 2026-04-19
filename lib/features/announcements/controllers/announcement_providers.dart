import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/announcement_repository.dart';
import '../models/announcement.dart';

/// Announcements for a specific section. Keyed by section id so each course
/// screen has its own independent list.
final sectionAnnouncementsProvider = FutureProvider.autoDispose
    .family<List<Announcement>, String>((ref, sectionId) {
  return ref
      .watch(announcementRepositoryProvider)
      .fetchForSection(sectionId);
});
