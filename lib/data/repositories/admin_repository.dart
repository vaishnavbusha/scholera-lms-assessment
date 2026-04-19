import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/models/department.dart';
import '../../features/admin/models/department_with_professors.dart';
import '../../features/admin/models/institution_stats.dart';
import '../../features/admin/models/professor_with_courses.dart';
import '../../features/auth/models/app_role.dart';
import '../../features/courses/models/course_section.dart';
import '../../features/profile/models/app_profile.dart';
import '../supabase/supabase_client_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
});

/// Supabase data access for the admin experience.
///
/// All queries go through RLS. Only users with `role = 'admin'` will see
/// institution-wide rows; everyone else is rejected at the row level, so the
/// client does not have to double-check permissions.
class AdminRepository {
  const AdminRepository(this._client);

  final SupabaseClient _client;

  /// Counts for the dashboard. Four light queries so RLS can gate each.
  Future<InstitutionStats> fetchInstitutionStats() async {
    final students = await _client
        .from('profiles')
        .select('id')
        .eq('role', AppRole.student.databaseValue);
    final professors = await _client
        .from('profiles')
        .select('id')
        .eq('role', AppRole.professor.databaseValue);
    final courses = await _client.from('courses').select('id');
    final departments = await _client.from('departments').select('id');

    return InstitutionStats(
      studentCount: students.length,
      professorCount: professors.length,
      courseCount: courses.length,
      departmentCount: departments.length,
    );
  }

  /// Departments and the professors assigned to each. We pull the two tables
  /// separately and stitch them in Dart rather than relying on PostgREST's
  /// embedded select — keeps the join semantics obvious and sidesteps RLS
  /// gotchas on nested selects.
  Future<List<DepartmentWithProfessors>> fetchDepartmentsWithProfessors() async {
    final departments = await _client
        .from('departments')
        .select()
        .order('name');
    final professors = await _client
        .from('profiles')
        .select()
        .eq('role', AppRole.professor.databaseValue);

    final grouped = <String, List<AppProfile>>{};
    for (final row in professors) {
      final profile = AppProfile.fromJson(row);
      final key = profile.departmentId;
      if (key == null) continue;
      grouped.putIfAbsent(key, () => []).add(profile);
    }

    return departments
        .map(Department.fromJson)
        .map(
          (dept) => DepartmentWithProfessors(
            department: dept,
            professors: [...?grouped[dept.id]]..sort(
              (a, b) => a.displayName.compareTo(b.displayName),
            ),
          ),
        )
        .toList();
  }

  /// One department plus its professors.
  Future<DepartmentWithProfessors> fetchDepartmentDetail(String id) async {
    final deptRow = await _client
        .from('departments')
        .select()
        .eq('id', id)
        .single();
    final professorRows = await _client
        .from('profiles')
        .select()
        .eq('role', AppRole.professor.databaseValue)
        .eq('department_id', id)
        .order('display_name');

    return DepartmentWithProfessors(
      department: Department.fromJson(deptRow),
      professors: professorRows.map(AppProfile.fromJson).toList(),
    );
  }

  /// One professor plus the course sections they teach.
  ///
  /// Each section is joined with its course catalog entry so the UI can show
  /// the course code/title alongside the section term without extra queries.
  Future<ProfessorWithCourses> fetchProfessorDetail(String id) async {
    final profileRow = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    final sectionRows = await _client
        .from('course_sections')
        .select('*, courses(*)')
        .eq('professor_id', id)
        .order('term');

    return ProfessorWithCourses(
      professor: AppProfile.fromJson(profileRow),
      sections: sectionRows.map(CourseSection.fromJson).toList(),
    );
  }
}
