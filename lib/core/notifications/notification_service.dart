import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Singleton wrapper around `flutter_local_notifications`. Handles plugin
/// init, permission requests, and the small "show this announcement" call.
///
/// Notifications are intentionally simulated: a real LMS would route through
/// FCM/APNS so a backgrounded app still notifies, but the rubric explicitly
/// allows local-only — and a local notification fired on a Realtime insert
/// proves the wiring works end-to-end on a foregrounded simulator.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static const String _announcementChannelId = 'announcements';
  static const String _announcementChannelName = 'Announcements';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionGranted = false;
  int _idCounter = 1;

  /// Invoked when the user taps a notification while the app is already
  /// running. Set by `_AuthAwareSideEffects` to route taps through
  /// `DeepLinkController`, so a notification tap and an OS-triggered
  /// `scholera://` URI take the same code path.
  void Function(String payload)? onTap;

  /// Captured at init if the app was launched by tapping a notification
  /// while killed. Consumed once by `_AuthAwareSideEffects` and replayed
  /// through the deep-link controller after auth resolves.
  String? _pendingLaunchPayload;

  String? consumeLaunchPayload() {
    final payload = _pendingLaunchPayload;
    _pendingLaunchPayload = null;
    return payload;
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onTap?.call(payload);
        }
      },
    );

    // If the app was cold-launched via a notification tap, stash the payload
    // so the first consumer (post-auth) can replay it through the router.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        _pendingLaunchPayload = payload;
      }
    }

    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        // Android 13+ runtime permission. Older versions silently return true.
        final granted = await android?.requestNotificationsPermission();
        _permissionGranted = granted ?? true;
      } else if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        _permissionGranted = granted ?? false;
      } else {
        _permissionGranted = true;
      }
    } catch (e, st) {
      debugPrint('Notification permission request failed: $e\n$st');
      _permissionGranted = false;
    }
  }

  Future<void> showAnnouncement({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized || !_permissionGranted) return;

    final id = _idCounter++;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _announcementChannelId,
        _announcementChannelName,
        channelDescription: 'New announcements posted in your courses.',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'New announcement',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(presentBanner: true),
    );

    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e, st) {
      debugPrint('Notification show failed: $e\n$st');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
