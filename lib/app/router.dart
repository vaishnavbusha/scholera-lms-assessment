import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/views/admin_home_screen.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/models/app_role.dart';
import '../features/professor/views/professor_courses_screen.dart';
import '../features/student/views/student_courses_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: LoginScreen.routePath,
    redirect: (context, state) {
      final sessionState = authState.value;
      final isLoggingIn = state.matchedLocation == LoginScreen.routePath;

      if (authState.isLoading || sessionState == null) {
        return null;
      }

      if (!sessionState.isSupabaseConfigured) {
        return isLoggingIn ? null : LoginScreen.routePath;
      }

      if (!sessionState.isAuthenticated) {
        return isLoggingIn ? null : LoginScreen.routePath;
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
        path: AdminHomeScreen.routePath,
        name: AdminHomeScreen.routeName,
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: ProfessorCoursesScreen.routePath,
        name: ProfessorCoursesScreen.routeName,
        builder: (context, state) => const ProfessorCoursesScreen(),
      ),
      GoRoute(
        path: StudentCoursesScreen.routePath,
        name: StudentCoursesScreen.routeName,
        builder: (context, state) => const StudentCoursesScreen(),
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
