import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/admin_repository.dart';
import '../models/department_with_professors.dart';
import '../models/institution_stats.dart';
import '../models/professor_with_courses.dart';

/// Institution stats card data for the admin dashboard.
final institutionStatsProvider = FutureProvider.autoDispose<InstitutionStats>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).fetchInstitutionStats();
});

/// Departments (with assigned professors) for the departments list screen.
final departmentsListProvider =
    FutureProvider.autoDispose<List<DepartmentWithProfessors>>((ref) {
      return ref.watch(adminRepositoryProvider).fetchDepartmentsWithProfessors();
    });

/// One department's detail, including its professors.
final departmentDetailProvider = FutureProvider.autoDispose
    .family<DepartmentWithProfessors, String>((ref, departmentId) {
      return ref
          .watch(adminRepositoryProvider)
          .fetchDepartmentDetail(departmentId);
    });

/// One professor's detail, including the course sections they teach.
final professorDetailProvider = FutureProvider.autoDispose
    .family<ProfessorWithCourses, String>((ref, professorId) {
      return ref
          .watch(adminRepositoryProvider)
          .fetchProfessorDetail(professorId);
    });
