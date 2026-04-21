class Topic {
  const Topic({
    required this.id,
    required this.moduleItemId,
    required this.title,
    this.confidence,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      moduleItemId: json['module_item_id'] as String,
      title: json['title'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String moduleItemId;
  final String title;
  final double? confidence;
}
