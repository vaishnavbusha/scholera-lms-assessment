import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/biometric/biometric_controller.dart';
import '../controllers/auth_controller.dart';

/// Shown between "signed in but session persisted across relaunch" and
/// "actually allowed into the app" when biometric unlock is enabled. Auto-
/// triggers the biometric prompt once on build; the user can retry or fall
/// back to signing out.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  static const routeName = 'unlock';
  static const routePath = '/unlock';

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  bool _attemptInFlight = false;
  bool _lastAttemptFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runUnlock());
  }

  Future<void> _runUnlock() async {
    if (_attemptInFlight) return;
    setState(() {
      _attemptInFlight = true;
      _lastAttemptFailed = false;
    });
    final ok = await ref.read(biometricControllerProvider.notifier).unlock();
    if (!mounted) return;
    setState(() {
      _attemptInFlight = false;
      _lastAttemptFailed = !ok;
    });
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                'Unlock Scholera',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                _lastAttemptFailed
                    ? 'Authentication was cancelled. Try again or sign out.'
                    : 'Verify it\u2019s you to get back into your account.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(flex: 3),
              FilledButton.icon(
                onPressed: _attemptInFlight ? null : _runUnlock,
                icon: _attemptInFlight
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Palette.surface,
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(_attemptInFlight ? 'Verifying\u2026' : 'Unlock'),
              ),
              const SizedBox(height: Spacing.md),
              TextButton(
                onPressed: _attemptInFlight ? null : _signOut,
                child: const Text('Sign out'),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Scholera',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Palette.inkSubtle,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
