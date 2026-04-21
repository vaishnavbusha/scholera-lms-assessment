import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/views/admin_home_screen.dart';
import '../features/admin/views/department_detail_screen.dart';
import '../features/admin/views/professor_detail_screen.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/models/app_role.dart';
import '../features/deep_links/deep_link_controller.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/professor/views/professor_course_screen.dart';
import '../features/professor/views/professor_courses_screen.dart';
import '../features/student/views/announcement_detail_screen.dart';
import '../features/student/views/student_course_screen.dart';
import '../features/student/views/student_courses_screen.dart';

/// The app's [GoRouter]. Created once per app lifetime.
///
/// It would be tempting to `ref.watch` the auth controller inside this
/// provider and derive the redirect from the watched state. Don't — every
/// auth transition (idle → loading → data) would recreate the router, which
/// tears down and rebuilds the whole navigator. Screens would lose their
/// state (the login screen would remount, losing typed text mid-sign-in).
///
/// Instead, hold a [ChangeNotifier] that re-fires on every auth change and
/// on every deep-link arrival, pass it as `refreshListenable`, and
/// `ref.read` the current auth and deep-link snapshots inside the
/// `redirect` callback. GoRouter re-evaluates redirects without rebuilding
/// the navigator.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: LoginScreen.routePath,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final sessionState = authState.value;
      final pendingLink = ref.read(deepLinkControllerProvider);
      final isLoggingIn = state.matchedLocation == LoginScreen.routePath;

      if (authState.isLoading || sessionState == null) {
        return null;
      }

      if (!sessionState.isSupabaseConfigured) {
        return isLoggingIn ? null : LoginScreen.routePath;
      }

      if (!sessionState.isAuthenticated) {
        // Leave the pending deep link alone so it can be consumed after
        // the user finishes signing in.
        return isLoggingIn ? null : LoginScreen.routePath;
      }

      // Authenticated: if there's a pending deep link that resolves to an
      // in-app path, consume it and route there.
      if (pendingLink != null) {
        final target = deepLinkToPath(pendingLink);
        ref.read(deepLinkControllerProvider.notifier).consume();
        if (target != null) return target;
      }

      if (isLoggingIn) {
        return _homePathForRole(sessionState.profile!.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: ProfileScreen.routePath,
        name: ProfileScreen.routeName,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AdminHomeScreen.routePath,
        name: AdminHomeScreen.routeName,
        builder: (context, state) => const AdminHomeScreen(),
        routes: [
          GoRoute(
            path: 'departments/:id',
            name: DepartmentDetailScreen.routeName,
            builder: (context, state) => DepartmentDetailScreen(
              departmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'professors/:id',
            name: ProfessorDetailScreen.routeName,
            builder: (context, state) => ProfessorDetailScreen(
              professorId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: ProfessorCoursesScreen.routePath,
        name: ProfessorCoursesScreen.routeName,
        builder: (context, state) => const ProfessorCoursesScreen(),
        routes: [
          GoRoute(
            path: ProfessorCourseScreen.routePath,
            name: ProfessorCourseScreen.routeName,
            builder: (context, state) => ProfessorCourseScreen(
              sectionId: state.pathParameters['sectionId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: StudentCoursesScreen.routePath,
        name: StudentCoursesScreen.routeName,
        builder: (context, state) => const StudentCoursesScreen(),
        routes: [
          GoRoute(
            path: StudentCourseScreen.routePath,
            name: StudentCourseScreen.routeName,
            builder: (context, state) => StudentCourseScreen(
              sectionId: state.pathParameters['sectionId']!,
            ),
            routes: [
              GoRoute(
                path: AnnouncementDetailScreen.routePath,
                name: AnnouncementDetailScreen.routeName,
                builder: (context, state) => AnnouncementDetailScreen(
                  sectionId: state.pathParameters['sectionId']!,
                  announcementId: state.pathParameters['announcementId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String _homePathForRole(AppRole role) {
  return switch (role) {
    AppRole.admin => AdminHomeScreen.routePath,
    AppRole.professor => ProfessorCoursesScreen.routePath,
    AppRole.student => StudentCoursesScreen.routePath,
  };
}

/// Bridges [authControllerProvider] and [deepLinkControllerProvider] into a
/// [Listenable] so GoRouter can re-run its redirect when auth state or a
/// pending deep link changes — without recreating the router itself.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _authSub = ref.listen<Object?>(
      authControllerProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
    _deepLinkSub = ref.listen<Object?>(
      deepLinkControllerProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  late final ProviderSubscription<Object?> _authSub;
  late final ProviderSubscription<Object?> _deepLinkSub;

  @override
  void dispose() {
    _authSub.close();
    _deepLinkSub.close();
    super.dispose();
  }
}
