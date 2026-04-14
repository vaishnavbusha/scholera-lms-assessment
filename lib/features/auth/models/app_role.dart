enum AppRole {
  admin,
  professor,
  student;

  static AppRole fromDatabase(String value) {
    return switch (value) {
      'admin' => AppRole.admin,
      'professor' => AppRole.professor,
      'student' => AppRole.student,
      _ => throw ArgumentError('Unsupported app role: $value'),
    };
  }

  String get label {
    return switch (this) {
      AppRole.admin => 'Admin',
      AppRole.professor => 'Professor',
      AppRole.student => 'Student',
    };
  }

  String get databaseValue {
    return switch (this) {
      AppRole.admin => 'admin',
      AppRole.professor => 'professor',
      AppRole.student => 'student',
    };
  }
}
