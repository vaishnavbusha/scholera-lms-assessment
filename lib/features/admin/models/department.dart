class Department {
  const Department({
    required this.id,
    required this.name,
    this.description,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  final String id;
  final String name;
  final String? description;
}
