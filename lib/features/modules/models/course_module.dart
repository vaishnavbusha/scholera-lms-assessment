import 'module_item.dart';

/// Called `CourseModule` because `Module` collides with Dart's `dart:core`
/// `Module` symbol in some toolchains. The database table is `modules`.
class CourseModule {
  const CourseModule({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.position,
    required this.items,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['module_items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final items = rawItems.map(ModuleItem.fromJson).toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return CourseModule(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      position: (json['position'] as num).toInt(),
      items: items,
    );
  }

  final String id;
  final String sectionId;
  final String title;
  final int position;
  final List<ModuleItem> items;
}
