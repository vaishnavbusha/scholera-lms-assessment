import 'module_item_type.dart';

class ModuleItem {
  const ModuleItem({
    required this.id,
    required this.moduleId,
    required this.sectionId,
    required this.title,
    required this.type,
    required this.position,
    this.url,
    this.body,
    this.storagePath,
  });

  factory ModuleItem.fromJson(Map<String, dynamic> json) {
    return ModuleItem(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      type: ModuleItemType.fromDatabase(json['item_type'] as String),
      position: (json['position'] as num).toInt(),
      url: json['url'] as String?,
      body: json['body'] as String?,
      storagePath: json['storage_path'] as String?,
    );
  }

  final String id;
  final String moduleId;
  final String sectionId;
  final String title;
  final ModuleItemType type;
  final int position;
  final String? url;
  final String? body;
  final String? storagePath;
}
