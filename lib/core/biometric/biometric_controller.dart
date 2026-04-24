import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../features/auth/controllers/auth_controller.dart';
import 'biometric_preferences.dart';

/// Runtime state for the biometric gate. Kept narrow on purpose — the router
/// only needs to know "is the user authenticated but still locked?".
enum BiometricGateState {
  /// Biometric disabled, hardware unavailable, or the user isn't signed in.
  /// Router should let the user through without an unlock screen.
  passthrough,

  /// Biometric is enabled and the user is signed in, but this launch hasn't
  /// unlocked yet. Router should redirect to /unlock.
  locked,

  /// Biometric is enabled and this launch has already been unlocked.
  unlocked,
}

class BiometricRuntime {
  const BiometricRuntime({
    required this.gate,
    required this.deviceAvailable,
    required this.enrolledForCurrentUser,
  });

  const BiometricRuntime.passthrough({
    this.deviceAvailable = false,
    this.enrolledForCurrentUser = false,
  }) : gate = BiometricGateState.passthrough;

  final BiometricGateState gate;
  final bool deviceAvailable;
  final bool enrolledForCurrentUser;

  BiometricRuntime copyWith({
    BiometricGateState? gate,
    bool? deviceAvailable,
    bool? enrolledForCurrentUser,
  }) {
    return BiometricRuntime(
      gate: gate ?? this.gate,
      deviceAvailable: deviceAvailable ?? this.deviceAvailable,
      enrolledForCurrentUser:
          enrolledForCurrentUser ?? this.enrolledForCurrentUser,
    );
  }
}

/// Drives biometric unlock. Reads auth state + stored preference, exposes
/// current gate state, and handles the actual [authenticate()] call.
final biometricControllerProvider =
    AsyncNotifierProvider<BiometricController, BiometricRuntime>(
  BiometricController.new,
);

class BiometricController extends AsyncNotifier<BiometricRuntime> {
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  Future<BiometricRuntime> build() async {
    final authState = ref.watch(authControllerProvider).value;
    final userId = authState?.profile?.id;

    final deviceAvailable = await _deviceSupportsBiometrics();

    if (userId == null) {
      return BiometricRuntime.passthrough(deviceAvailable: deviceAvailable);
    }

    final prefs = await ref.watch(biometricPreferencesProvider.future);
    final enrolled = prefs.isEnabled(userId);

    if (!enrolled || !deviceAvailable) {
      return BiometricRuntime(
        gate: BiometricGateState.passthrough,
        deviceAvailable: deviceAvailable,
        enrolledForCurrentUser: enrolled,
      );
    }

    return BiometricRuntime(
      gate: BiometricGateState.locked,
      deviceAvailable: deviceAvailable,
      enrolledForCurrentUser: true,
    );
  }

  Future<bool> _deviceSupportsBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return canCheck && supported;
    } catch (e, st) {
      debugPrint('Biometric capability check failed: $e\n$st');
      return false;
    }
  }

  /// Prompts biometric and, on success, transitions the gate to [unlocked].
  /// Returns true on success, false on cancel/failure.
  Future<bool> unlock() async {
    final current = state.value;
    if (current == null) return false;

    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock Scholera to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (ok) {
        state = AsyncData(
          current.copyWith(gate: BiometricGateState.unlocked),
        );
        return true;
      }
      return false;
    } catch (e, st) {
      debugPrint('Biometric unlock failed: $e\n$st');
      return false;
    }
  }

  /// Opts the current user into biometric unlock. Runs the biometric prompt
  /// once up-front to confirm it works on this device. Returns true on
  /// success.
  Future<bool> enableForCurrentUser() async {
    final authState = ref.read(authControllerProvider).value;
    final userId = authState?.profile?.id;
    if (userId == null) return false;

    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Enable biometric unlock for Scholera',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!ok) return false;

      final prefs = await ref.read(biometricPreferencesProvider.future);
      await prefs.setEnabled(userId, true);
      await prefs.markPrompted(userId);

      final current = state.value;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            gate: BiometricGateState.unlocked,
            enrolledForCurrentUser: true,
          ),
        );
      }
      return true;
    } catch (e, st) {
      debugPrint('Biometric enroll failed: $e\n$st');
      return false;
    }
  }

  Future<void> disableForCurrentUser() async {
    final authState = ref.read(authControllerProvider).value;
    final userId = authState?.profile?.id;
    if (userId == null) return;

    final prefs = await ref.read(biometricPreferencesProvider.future);
    await prefs.setEnabled(userId, false);

    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          gate: BiometricGateState.passthrough,
          enrolledForCurrentUser: false,
        ),
      );
    }
  }

  /// Records that we've offered biometric opt-in to this user so we don't
  /// nag them again on every launch.
  Future<void> markOptInPrompted() async {
    final authState = ref.read(authControllerProvider).value;
    final userId = authState?.profile?.id;
    if (userId == null) return;

    final prefs = await ref.read(biometricPreferencesProvider.future);
    await prefs.markPrompted(userId);
  }
}
