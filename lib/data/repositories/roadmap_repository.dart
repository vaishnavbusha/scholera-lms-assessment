import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/widgets/status_pill.dart';
import '../../features/roadmap/models/roadmap_module.dart';
import '../supabase/supabase_client_provider.dart';

final roadmapRepositoryProvider = Provider<RoadmapRepository>((ref) {
  return RoadmapRepository(ref.watch(supabaseClientProvider));
});

/// Roadmap reads and writes. The roadmap tree is modules → items → (topics,
/// professor coverage, student progress). One query returns the whole thing
/// for a section via nested PostgREST selects.
class RoadmapRepository {
  const RoadmapRepository(this._client);

  final SupabaseClient _client;

  /// Roadmap for the professor side — no student-progress join.
  Future<List<RoadmapModule>> fetchProfessorRoadmap(String sectionId) async {
    final rows = await _client
        .from('modules')
        .select('*, module_items(*, topics(*), roadmap_nodes(*))')
        .eq('section_id', sectionId)
        .order('position');
    return rows.map(RoadmapModule.fromJson).toList();
  }

  /// Roadmap for the student side — includes [student_progress] joined per
  /// item, filtered to the requested student id.
  Future<List<RoadmapModule>> fetchStudentRoadmap({
    required String sectionId,
    required String studentId,
  }) async {
    final rows = await _client
        .from('modules')
        .select(
          '*, module_items(*, topics(*), roadmap_nodes(*), '
          'student_progress(*))',
        )
        .eq('section_id', sectionId)
        .eq('module_items.student_progress.student_id', studentId)
        .order('position');
    return rows.map(RoadmapModule.fromJson).toList();
  }

  /// Update the professor coverage status for a specific roadmap node. RLS
  /// restricts this to the owning professor.
  Future<void> updateProfessorStatus({
    required String moduleItemId,
    required ProgressStatus status,
  }) async {
    await _client
        .from('roadmap_nodes')
        .update({'professor_status': status.databaseValue})
        .eq('module_item_id', moduleItemId);
  }

  /// Upsert the student's own progress for one item. The `student_progress`
  /// table has a unique constraint on (student_id, module_item_id).
  Future<void> upsertStudentStatus({
    required String studentId,
    required String moduleItemId,
    required ProgressStatus status,
  }) async {
    await _client.from('student_progress').upsert({
      'student_id': studentId,
      'module_item_id': moduleItemId,
      'status': status.databaseValue,
    }, onConflict: 'student_id,module_item_id');
  }
}
