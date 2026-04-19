import 'package:flutter/material.dart';

import '../../features/auth/models/app_role.dart';
import 'app_theme.dart';
import 'role_theme.dart';

/// Wraps a subtree in the [ThemeData] for a given [RoleTheme].
///
/// Each role's home screen uses this at the top of its tree; every descendant
/// widget (including shared primitives) then reads its accent color from
/// `Theme.of(context)`. Nothing below needs a `role` parameter.
class RoleThemeScope extends StatelessWidget {
  const RoleThemeScope({
    required this.role,
    required this.child,
    super.key,
  });

  factory RoleThemeScope.forAppRole({
    required AppRole role,
    required Widget child,
  }) {
    return RoleThemeScope(role: RoleTheme.forRole(role), child: child);
  }

  /// The neutral (role-less) shell used on pre-auth screens.
  factory RoleThemeScope.neutral({required Widget child}) {
    return RoleThemeScope(role: RoleTheme.neutral, child: child);
  }

  final RoleTheme role;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _CurrentRoleTheme(
      role: role,
      child: Theme(data: buildAppTheme(role), child: child),
    );
  }

  /// Read the active role theme from the nearest [RoleThemeScope] ancestor.
  /// Returns the neutral theme if no scope is present.
  static RoleTheme of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_CurrentRoleTheme>();
    return inherited?.role ?? RoleTheme.neutral;
  }
}

class _CurrentRoleTheme extends InheritedWidget {
  const _CurrentRoleTheme({required this.role, required super.child});

  final RoleTheme role;

  @override
  bool updateShouldNotify(_CurrentRoleTheme oldWidget) =>
      oldWidget.role != role;
}
