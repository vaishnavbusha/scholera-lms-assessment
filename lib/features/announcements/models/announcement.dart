class Announcement {
  const Announcement({
    required this.id,
    required this.sectionId,
    required this.professorId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      professorId: json['professor_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String sectionId;
  final String professorId;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
}
