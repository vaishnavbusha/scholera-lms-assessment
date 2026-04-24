import '../../../core/widgets/status_pill.dart';
import '../../modules/models/module_item_type.dart';
import 'topic.dart';

/// A module item as seen on the roadmap: title + type + extracted topics +
/// the professor's coverage status. For the student roadmap, [studentStatus]
/// is populated separately; professor views leave it null.
class RoadmapItem {
  const RoadmapItem({
    required this.id,
    required this.moduleId,
    required this.sectionId,
    required this.title,
    required this.type,
    required this.position,
    required this.topics,
    required this.professorStatus,
    this.studentStatus,
    this.storagePath,
  });

  factory RoadmapItem.fromJson(Map<String, dynamic> json) {
    final topics = _asRowList(json['topics']).map(Topic.fromJson).toList();

    // roadmap_nodes has UNIQUE(module_item_id) so PostgREST may return the
    // embedded field as either a list (length 0 or 1) or a single object.
    // Handle both shapes.
    final nodes = _asRowList(json['roadmap_nodes']);
    final professorStatus = nodes.isEmpty
        ? ProgressStatus.notStarted
        : ProgressStatus.fromDatabase(
            nodes.first['professor_status'] as String,
          );

    final progress = _asRowList(json['student_progress']);
    final studentStatus = progress.isEmpty
        ? null
        : ProgressStatus.fromDatabase(progress.first['status'] as String);

    return RoadmapItem(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      type: ModuleItemType.fromDatabase(json['item_type'] as String),
      position: (json['position'] as num).toInt(),
      topics: topics,
      professorStatus: professorStatus,
      studentStatus: studentStatus,
      storagePath: json['storage_path'] as String?,
    );
  }

  final String id;
  final String moduleId;
  final String sectionId;
  final String title;
  final ModuleItemType type;
  final int position;
  final List<Topic> topics;
  final ProgressStatus professorStatus;
  final ProgressStatus? studentStatus;
  final String? storagePath;

  RoadmapItem copyWith({
    ProgressStatus? professorStatus,
    ProgressStatus? studentStatus,
  }) {
    return RoadmapItem(
      id: id,
      moduleId: moduleId,
      sectionId: sectionId,
      title: title,
      type: type,
      position: position,
      topics: topics,
      professorStatus: professorStatus ?? this.professorStatus,
      studentStatus: studentStatus ?? this.studentStatus,
      storagePath: storagePath,
    );
  }
}

/// Normalizes an embedded PostgREST field into a list of maps, regardless of
/// whether the server returned it as a list or as a single object (which can
/// happen on 1-to-1 relationships with a unique constraint).
List<Map<String, dynamic>> _asRowList(Object? value) {
  if (value == null) return const [];
  if (value is Map<String, dynamic>) return [value];
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }
  return const [];
}
