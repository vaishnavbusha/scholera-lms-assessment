import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/models/app_profile.dart';
import 'auth_controller.dart';

/// The currently-authenticated profile. Throws if accessed before auth
/// resolves — screens behind the auth redirect can rely on it being present.
final currentProfileProvider = Provider<AppProfile>((ref) {
  final state = ref.watch(authControllerProvider).value;
  final profile = state?.profile;
  if (profile == null) {
    throw StateError(
      'currentProfileProvider read before authentication completed.',
    );
  }
  return profile;
});
