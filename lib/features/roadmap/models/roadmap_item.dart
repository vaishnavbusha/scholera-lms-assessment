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
  });

  factory RoadmapItem.fromJson(Map<String, dynamic> json) {
    final rawTopics = (json['topics'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final topics = rawTopics.map(Topic.fromJson).toList();

    final rawNodes = (json['roadmap_nodes'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final professorStatus = rawNodes.isEmpty
        ? ProgressStatus.notStarted
        : ProgressStatus.fromDatabase(
            rawNodes.first['professor_status'] as String,
          );

    final rawProgress =
        (json['student_progress'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
    final studentStatus = rawProgress.isEmpty
        ? null
        : ProgressStatus.fromDatabase(rawProgress.first['status'] as String);

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
}
