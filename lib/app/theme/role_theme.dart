import 'package:flutter/material.dart';

import '../../features/auth/models/app_role.dart';
import 'palette.dart';

/// Role-scoped accent data. A [RoleTheme] is the source of truth for a role's
/// primary color; the rest of the theme is reused across roles so the app
/// feels cohesive.
class RoleTheme {
  const RoleTheme({
    required this.primary,
    required this.primaryHover,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.label,
  });

  final Color primary;
  final Color primaryHover;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final String label;

  static const RoleTheme admin = RoleTheme(
    primary: Palette.adminPrimary,
    primaryHover: Palette.adminPrimaryHover,
    primaryContainer: Palette.adminContainer,
    onPrimaryContainer: Palette.adminOnContainer,
    label: 'Admin',
  );

  static const RoleTheme professor = RoleTheme(
    primary: Palette.professorPrimary,
    primaryHover: Palette.professorPrimaryHover,
    primaryContainer: Palette.professorContainer,
    onPrimaryContainer: Palette.professorOnContainer,
    label: 'Professor',
  );

  static const RoleTheme student = RoleTheme(
    primary: Palette.studentPrimary,
    primaryHover: Palette.studentPrimaryHover,
    primaryContainer: Palette.studentContainer,
    onPrimaryContainer: Palette.studentOnContainer,
    label: 'Student',
  );

  /// The neutral theme used on pre-auth screens (login, splash).
  static const RoleTheme neutral = RoleTheme(
    primary: Palette.neutralPrimary,
    primaryHover: Palette.neutralPrimaryHover,
    primaryContainer: Palette.neutralContainer,
    onPrimaryContainer: Palette.neutralOnContainer,
    label: 'Scholera',
  );

  static RoleTheme forRole(AppRole role) {
    return switch (role) {
      AppRole.admin => admin,
      AppRole.professor => professor,
      AppRole.student => student,
    };
  }
}
