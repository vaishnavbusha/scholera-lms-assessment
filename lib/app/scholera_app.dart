import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/biometric/biometric_controller.dart';
import '../core/biometric/biometric_preferences.dart';
import '../core/notifications/notification_service.dart';
import '../features/announcements/controllers/announcement_notification_listener.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/deep_links/deep_link_controller.dart';
import 'router.dart' show appRouterProvider, rootNavigatorKey;
import 'theme/app_theme.dart';
import 'theme/role_theme.dart';

class ScholeraApp extends ConsumerWidget {
  const ScholeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // The default theme is the neutral (pre-auth) palette. Role shells wrap
    // their subtrees in [RoleThemeScope] to apply the admin/professor/
    // student accent.
    return MaterialApp.router(
      title: 'Scholera',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(RoleTheme.neutral),
      routerConfig: router,
      builder: (context, child) {
        return _AuthAwareSideEffects(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// Mounts auth-scoped side effects (realtime notifications, biometric opt-in
/// prompt) only while a user is signed in. Keeps its subscriptions alive
/// across screen navigations.
class _AuthAwareSideEffects extends ConsumerStatefulWidget {
  const _AuthAwareSideEffects({required this.child});

  final Widget child;

  @override
  ConsumerState<_AuthAwareSideEffects> createState() =>
      _AuthAwareSideEffectsState();
}

class _AuthAwareSideEffectsState extends ConsumerState<_AuthAwareSideEffects> {
  String? _optInCheckedForUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Runtime taps — user taps a notification while the app is running.
      NotificationService.instance.onTap = (payload) {
        final uri = Uri.tryParse(payload);
        if (uri == null) return;
        ref.read(deepLinkControllerProvider.notifier).receive(uri);
      };

      // Cold-start tap — app was killed when the user tapped the
      // notification, so we stashed the payload at plugin init. Replay it
      // through the same pipe; the router's redirect will buffer it until
      // auth resolves, exactly like an OS-originated scholera:// URI.
      final launch = NotificationService.instance.consumeLaunchPayload();
      if (launch != null) {
        final uri = Uri.tryParse(launch);
        if (uri != null) {
          ref.read(deepLinkControllerProvider.notifier).receive(uri);
        }
      }
    });
  }

  @override
  void dispose() {
    NotificationService.instance.onTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.value;
    final isAuthenticated = session?.isAuthenticated ?? false;

    if (isAuthenticated) {
      ref.watch(announcementNotificationListenerProvider);
      _maybeOfferBiometricOptIn(session!.profile!.id);
    }

    return widget.child;
  }

  /// Once per sign-in, offer biometric opt-in if the device supports it and
  /// the user hasn't been prompted before. Guards with `_optInCheckedForUser`
  /// so we don't re-check on every rebuild.
  Future<void> _maybeOfferBiometricOptIn(String userId) async {
    if (_optInCheckedForUser == userId) return;
    _optInCheckedForUser = userId;

    // Let the first frame settle so the role home is visible before the
    // dialog lands. Avoids showing the dialog while the route transition
    // is still in flight.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final runtime = ref.read(biometricControllerProvider).value;
    if (runtime == null) return;
    if (!runtime.deviceAvailable) return;
    if (runtime.enrolledForCurrentUser) return;

    final prefs = await ref.read(biometricPreferencesProvider.future);
    if (prefs.hasBeenPrompted(userId)) return;
    if (!mounted) return;

    // MaterialApp.router's builder context sits *above* the Navigator, so
    // showDialog needs the root Navigator's context instead — that's what
    // the GoRouter navigatorKey exposes. The context is freshly resolved
    // from the GlobalKey right here, so the async-gap concern doesn't apply.
    final dialogContext = rootNavigatorKey.currentContext;
    if (dialogContext == null) return;

    final accepted = await showDialog<bool>(
      context: dialogContext, // ignore: use_build_context_synchronously
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Unlock with biometrics?'),
          content: const Text(
            'Use Face ID or fingerprint to sign in faster on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    await ref.read(biometricControllerProvider.notifier).markOptInPrompted();
    if (accepted == true) {
      await ref.read(biometricControllerProvider.notifier).enableForCurrentUser();
    }
  }
}
