import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/module_repository.dart';
import '../models/course_module.dart';

/// Modules (with embedded items) for a section. Keyed by section id.
final sectionModulesProvider = FutureProvider.autoDispose
    .family<List<CourseModule>, String>((ref, sectionId) {
  return ref.watch(moduleRepositoryProvider).fetchModulesWithItems(sectionId);
});
