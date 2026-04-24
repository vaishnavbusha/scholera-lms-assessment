import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refresh_rate/refresh_rate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/env.dart';
import 'app/scholera_app.dart';
import 'core/notifications/notification_service.dart';
import 'data/supabase/supabase_client_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _enableHighRefreshRate();

  final env = AppEnv.current;
  final isSupabaseConfigured = env.hasSupabaseConfig;

  if (isSupabaseConfigured) {
    await Supabase.initialize(
      url: env.supabaseUrl,
      anonKey: env.supabaseAnonKey,
    );
  }

  // Best-effort: a denied permission shouldn't block app launch — the
  // service no-ops in that case.
  await NotificationService.instance.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        supabaseConfiguredProvider.overrideWithValue(isSupabaseConfigured),
      ],
      child: const ScholeraApp(),
    ),
  );
}

/// Opts the app into the device's highest available refresh rate.
///
/// Uses the `refresh_rate` package which picks the most effective API per
/// platform + API level:
/// - Android 14+ (API 34+): `SurfaceControl.Transaction.setFrameRate()`
/// - Android 11–13 (API 30–33): dual hints via `preferredRefreshRate` +
///   `preferredDisplayModeId`
/// - Android 6–10 (API 23–29): legacy `preferredDisplayModeId` fallback
/// - iOS (ProMotion, iOS 15+): honored via `CADisableMinimumFrameDurationOnPhone`
///   in `ios/Runner/Info.plist` (already set).
///
/// Flutter defaults to 60Hz even on 90/120Hz panels, so scrolling and
/// animations look choppier than the device is capable of.
Future<void> _enableHighRefreshRate() async {
  try {
    RefreshRate.enable();
    RefreshRate.preferMax();
    final info = await RefreshRate.refresh();
    debugPrint(
      'Refresh rate — current: ${info.currentRate}Hz, '
      'max: ${info.maxRate}Hz, engine target: ${info.engineTargetRate}Hz, '
      'supported: ${info.supportedRates.join(", ")}Hz',
    );
  } catch (e, st) {
    // Some OEM ROMs block refresh-rate voting for third-party apps; missing
    // the bump is not a launch blocker.
    debugPrint('Could not enable high refresh rate: $e\n$st');
  }
}
