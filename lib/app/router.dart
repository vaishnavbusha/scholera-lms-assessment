import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/views/admin_home_screen.dart';
import '../features/auth/views/login_screen.dart';
import '../features/professor/views/professor_courses_screen.dart';
import '../features/student/views/student_courses_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: LoginScreen.routePath,
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
