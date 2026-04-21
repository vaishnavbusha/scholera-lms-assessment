import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/course_repository.dart';
import '../../auth/controllers/current_profile_provider.dart';
import '../../courses/models/course_section.dart';

/// Course sections the current student is enrolled in.
final studentCourseSectionsProvider = FutureProvider.autoDispose<
    List<CourseSection>>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return ref
      .watch(courseRepositoryProvider)
      .fetchStudentCourseSections(profile.id);
});

/// One section detail for the student side. Keyed by section id.
final studentCourseSectionProvider = FutureProvider.autoDispose
    .family<CourseSection, String>((ref, sectionId) {
  return ref.watch(courseRepositoryProvider).fetchSection(sectionId);
});
