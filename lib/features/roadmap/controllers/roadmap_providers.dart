import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/roadmap_repository.dart';
import '../models/roadmap_module.dart';

/// Roadmap for the professor view of a section. Does not include student
/// progress — only professor coverage.
final professorRoadmapProvider = FutureProvider.autoDispose
    .family<List<RoadmapModule>, String>((ref, sectionId) {
  return ref
      .watch(roadmapRepositoryProvider)
      .fetchProfessorRoadmap(sectionId);
});

/// Roadmap for the student view of a section. Filtered to the current
/// student's progress rows. The family key combines section and student so
/// two different students looking at the same section don't share state.
typedef StudentRoadmapKey = ({String sectionId, String studentId});

final studentRoadmapProvider = FutureProvider.autoDispose
    .family<List<RoadmapModule>, StudentRoadmapKey>((ref, key) {
  return ref.watch(roadmapRepositoryProvider).fetchStudentRoadmap(
        sectionId: key.sectionId,
        studentId: key.studentId,
      );
});
