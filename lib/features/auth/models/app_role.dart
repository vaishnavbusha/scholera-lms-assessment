enum AppRole {
  admin,
  professor,
  student;

  String get label {
    return switch (this) {
      AppRole.admin => 'Admin',
      AppRole.professor => 'Professor',
      AppRole.student => 'Student',
    };
  }
}
