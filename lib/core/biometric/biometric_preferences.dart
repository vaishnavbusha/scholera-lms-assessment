import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around shared_preferences for biometric opt-in state.
/// Scoped by user id so enabling biometric for one account doesn't leak the
/// setting to another.
class BiometricPreferences {
  BiometricPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _promptedKey = 'biometric_prompted_user_ids';
  static const _enabledKey = 'biometric_enabled_user_ids';

  bool isEnabled(String userId) {
    return _prefs.getStringList(_enabledKey)?.contains(userId) ?? false;
  }

  bool hasBeenPrompted(String userId) {
    return _prefs.getStringList(_promptedKey)?.contains(userId) ?? false;
  }

  Future<void> setEnabled(String userId, bool enabled) async {
    final set = (_prefs.getStringList(_enabledKey) ?? const <String>[]).toSet();
    if (enabled) {
      set.add(userId);
    } else {
      set.remove(userId);
    }
    await _prefs.setStringList(_enabledKey, set.toList());
  }

  Future<void> markPrompted(String userId) async {
    final set = (_prefs.getStringList(_promptedKey) ?? const <String>[]).toSet();
    set.add(userId);
    await _prefs.setStringList(_promptedKey, set.toList());
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final biometricPreferencesProvider = FutureProvider<BiometricPreferences>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return BiometricPreferences(prefs);
});
