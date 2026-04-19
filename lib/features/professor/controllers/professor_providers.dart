import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/course_repository.dart';
import '../../auth/controllers/current_profile_provider.dart';
import '../../courses/models/course_section.dart';

/// Course sections the current professor teaches.
final professorCourseSectionsProvider = FutureProvider.autoDispose<
    List<CourseSection>>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return ref
      .watch(courseRepositoryProvider)
      .fetchProfessorCourseSections(profile.id);
});

/// One course section (with joined course). Cached per section id.
final professorCourseSectionProvider = FutureProvider.autoDispose
    .family<CourseSection, String>((ref, sectionId) {
  return ref.watch(courseRepositoryProvider).fetchSection(sectionId);
});
