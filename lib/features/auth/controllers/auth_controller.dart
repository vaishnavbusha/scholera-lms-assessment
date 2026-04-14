import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/supabase/supabase_client_provider.dart';
import '../../profile/models/app_profile.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSessionState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSessionState> {
  @override
  Future<AuthSessionState> build() async {
    final isConfigured = ref.watch(supabaseConfiguredProvider);

    if (!isConfigured) {
      return const AuthSessionState.unconfigured();
    }

    final authRepository = ref.watch(authRepositoryProvider);
    final session = authRepository.currentSession;

    if (session == null) {
      return const AuthSessionState.signedOut();
    }

    final profile = await ref
        .watch(profileRepositoryProvider)
        .fetchCurrentProfile();

    return AuthSessionState.authenticated(session: session, profile: profile);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading<AuthSessionState>();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final profileRepository = ref.read(profileRepositoryProvider);
      final response = await authRepository.signInWithPassword(
        email: email,
        password: password,
      );
      final session = response.session ?? authRepository.currentSession;

      if (session == null) {
        throw const AuthException('Sign in did not return a session.');
      }

      final profile = await profileRepository.fetchCurrentProfile();

      return AuthSessionState.authenticated(session: session, profile: profile);
    });
  }

  Future<void> signOut() async {
    final isConfigured = ref.read(supabaseConfiguredProvider);

    if (!isConfigured) {
      state = const AsyncData(AuthSessionState.unconfigured());
      return;
    }

    state = const AsyncLoading<AuthSessionState>();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return const AuthSessionState.signedOut();
    });
  }
}

class AuthSessionState {
  const AuthSessionState._({
    required this.isSupabaseConfigured,
    required this.session,
    required this.profile,
  });

  const AuthSessionState.unconfigured()
    : this._(isSupabaseConfigured: false, session: null, profile: null);

  const AuthSessionState.signedOut()
    : this._(isSupabaseConfigured: true, session: null, profile: null);

  const AuthSessionState.authenticated({
    required Session this.session,
    required AppProfile this.profile,
  }) : isSupabaseConfigured = true;

  final bool isSupabaseConfigured;
  final Session? session;
  final AppProfile? profile;

  bool get isAuthenticated => session != null && profile != null;
}
