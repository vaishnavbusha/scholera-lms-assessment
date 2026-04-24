import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/notifications/notification_preferences.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../data/supabase/supabase_client_provider.dart';
import '../../auth/controllers/current_profile_provider.dart';
import '../../auth/models/app_role.dart';

/// Subscribes to all announcement inserts the user can read (RLS-scoped via
/// supabase_realtime) and pops a local notification for each one. Skips:
/// - the user's own posts (professor posting an announcement)
/// - rows older than 30s (backfill / replay safety)
///
/// The provider is `keepAlive` because it should survive screen navigation —
/// otherwise a notification only fires while the user is on the announcements
/// tab, defeating the point. The app shell `ref.watch`es it once after auth.
final announcementNotificationListenerProvider = Provider<void>((ref) {
  final profile = ref.watch(currentProfileProvider);
  final client = ref.watch(supabaseClientProvider);
  final notifications = ref.watch(notificationServiceProvider);

  // Resolve the professor display name once so the notification body reads
  // like "Prof. Patel posted: Midterm review on Friday" instead of a raw uuid.
  Future<String?> resolveProfessorName(String professorId) async {
    try {
      final row = await client
          .from('profiles')
          .select('display_name')
          .eq('id', professorId)
          .maybeSingle();
      return row?['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  final channel = client
      .channel('global-announcement-notifications-${profile.id}')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'announcements',
        callback: (payload) async {
          final row = payload.newRecord;
          final announcementId = row['id'] as String?;
          final sectionId = row['section_id'] as String?;
          final professorId = row['professor_id'] as String?;
          final title = row['title'] as String? ?? 'New announcement';
          final body = row['body'] as String? ?? '';
          final createdAt = DateTime.tryParse(
            row['created_at'] as String? ?? '',
          );

          // Skip self-posts: a professor posting their own announcement
          // shouldn't get a notification for it.
          if (professorId == profile.id) return;

          // Skip stale rows (initial backfill / replay).
          if (createdAt != null &&
              DateTime.now().difference(createdAt).inSeconds > 30) {
            return;
          }

          // Admins see every announcement in the institution; that's noisy.
          // Restrict notifications to professors and students.
          if (profile.role == AppRole.admin) return;

          // User-level opt-out via the Profile screen toggle. OS permission
          // is the outer gate; this is the in-app "do not disturb" flag.
          final notificationPrefs = await ref.read(
            notificationPreferencesProvider.future,
          );
          if (!notificationPrefs.isEnabled(profile.id)) return;

          final senderName = professorId == null
              ? null
              : await resolveProfessorName(professorId);
          final headline = senderName == null
              ? title
              : '$senderName: $title';

          // Payload is a scholera:// URL so tapping the notification goes
          // through DeepLinkController → router, the same path as an OS
          // deep link. Only set when both ids are present; students only
          // deep-link to their course detail + announcement.
          final deepLink = (sectionId != null && announcementId != null)
              ? 'scholera://courses/$sectionId/announcements/$announcementId'
              : null;

          await notifications.showAnnouncement(
            title: headline,
            body: body,
            payload: deepLink,
          );
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
  });
});
