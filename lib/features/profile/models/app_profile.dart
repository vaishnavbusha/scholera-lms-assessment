import '../../auth/models/app_role.dart';

class AppProfile {
  const AppProfile({
    required this.id,
    required this.role,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.departmentId,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: json['id'] as String,
      role: AppRole.fromDatabase(json['role'] as String),
      displayName: json['display_name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      departmentId: json['department_id'] as String?,
    );
  }

  final String id;
  final AppRole role;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final String? departmentId;
}
