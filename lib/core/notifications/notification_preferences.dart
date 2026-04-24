import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../biometric/biometric_preferences.dart';

/// Thin wrapper around shared_preferences for the per-user notifications
/// toggle. Users are opted in by default (matches platform convention —
/// permission grant is consent); the toggle exists so they can silence the
/// app without revoking OS-level permission.
class NotificationPreferences {
  NotificationPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _mutedKey = 'notifications_muted_user_ids';

  bool isEnabled(String userId) {
    final muted = _prefs.getStringList(_mutedKey) ?? const <String>[];
    return !muted.contains(userId);
  }

  Future<void> setEnabled(String userId, bool enabled) async {
    final muted = (_prefs.getStringList(_mutedKey) ?? const <String>[]).toSet();
    if (enabled) {
      muted.remove(userId);
    } else {
      muted.add(userId);
    }
    await _prefs.setStringList(_mutedKey, muted.toList());
  }
}

final notificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return NotificationPreferences(prefs);
});
