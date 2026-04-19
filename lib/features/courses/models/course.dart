class Course {
  const Course({
    required this.id,
    required this.departmentId,
    required this.code,
    required this.title,
    this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      departmentId: json['department_id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
    );
  }

  final String id;
  final String departmentId;
  final String code;
  final String title;
  final String? description;
}
