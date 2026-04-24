import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Listens for incoming `scholera://...` URIs from the OS and exposes the
/// most recent one as state. The router reads this value and consumes it
/// after authentication — if a link arrives while the user is signed out,
/// it stays pending until they finish signing in.
final deepLinkControllerProvider = NotifierProvider<DeepLinkController, Uri?>(
  () => DeepLinkController(),
);

class DeepLinkController extends Notifier<Uri?> {
  StreamSubscription<Uri>? _subscription;

  @override
  Uri? build() {
    final appLinks = AppLinks();

    // Cold-start URI (the one that launched the app from a deep link).
    appLinks.getInitialLink().then((uri) {
      if (uri != null && state == null) {
        state = uri;
      }
    });

    // Runtime URIs that arrive while the app is already open.
    _subscription = appLinks.uriLinkStream.listen((uri) {
      state = uri;
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return null;
  }

  /// Clear the pending link once the router has routed to it.
  void consume() {
    state = null;
  }

  /// Inject a deep link from a non-OS source (e.g. tapping a local
  /// notification). Takes the same path as an OS-originated scholera:// URI
  /// so the router handles both identically — replay after auth included.
  void receive(Uri uri) {
    state = uri;
  }
}

/// Maps a recognised `scholera://` deep link to the corresponding in-app
/// GoRouter path. Returns null if the URI is not a supported shape.
///
/// Currently supports: `scholera://courses/{sectionId}/announcements/{id}`
/// → `/student/courses/{sectionId}/announcements/{id}`.
String? deepLinkToPath(Uri uri) {
  if (uri.scheme != 'scholera') return null;
  if (uri.host != 'courses') return null;

  final segs = uri.pathSegments;
  if (segs.length == 3 && segs[1] == 'announcements') {
    final sectionId = segs[0];
    final announcementId = segs[2];
    return '/student/courses/$sectionId/announcements/$announcementId';
  }
  return null;
}
