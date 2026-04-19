import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/courses/models/course_section.dart';
import '../supabase/supabase_client_provider.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(ref.watch(supabaseClientProvider));
});

/// Supabase data access for course sections. Used by professor and student
/// surfaces alike — RLS gates visibility, so both call the same queries.
class CourseRepository {
  const CourseRepository(this._client);

  final SupabaseClient _client;

  /// Course sections a professor teaches. Joined with [Course] so screens
  /// can render code/title without a second query.
  Future<List<CourseSection>> fetchProfessorCourseSections(
    String professorId,
  ) async {
    final rows = await _client
        .from('course_sections')
        .select('*, courses(*)')
        .eq('professor_id', professorId)
        .order('term');

    return rows.map(CourseSection.fromJson).toList();
  }

  /// Course sections a student is enrolled in. Joined with [Course].
  Future<List<CourseSection>> fetchStudentCourseSections(
    String studentId,
  ) async {
    final rows = await _client
        .from('enrollments')
        .select('course_sections(*, courses(*))')
        .eq('student_id', studentId);

    return rows
        .map((row) => row['course_sections'] as Map<String, dynamic>)
        .map(CourseSection.fromJson)
        .toList();
  }

  /// One section with joined course data. Used by the course management /
  /// course detail screens after navigation.
  Future<CourseSection> fetchSection(String sectionId) async {
    final row = await _client
        .from('course_sections')
        .select('*, courses(*)')
        .eq('id', sectionId)
        .single();
    return CourseSection.fromJson(row);
  }
}
