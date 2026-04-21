import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/role_theme_scope.dart';
import '../../app/theme/tokens.dart';

/// Tiny role indicator — a single serif letter (A / P / S) in a soft tinted
/// circle. Sits in app bars and profile cards so the current role is
/// glanceable without shouting.
class RoleBadge extends StatelessWidget {
  const RoleBadge({
    this.size = 32,
    this.showLabel = false,
    this.onTap,
    super.key,
  });

  final double size;

  /// When true, shows "Admin" / "Professor" / "Student" next to the badge.
  final bool showLabel;

  /// Optional tap handler. When provided the badge is wrapped in an InkWell,
  /// which is how role homes surface profile access without a separate icon
  /// button cluttering the app bar.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final role = RoleThemeScope.of(context);
    final initial = role.label.isEmpty ? '·' : role.label[0].toUpperCase();

    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: role.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: role.primary.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.plusJakartaSans(
          color: role.onPrimaryContainer,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );

    final content = !showLabel
        ? badge
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              badge,
              const SizedBox(width: Spacing.sm),
              Text(
                role.label,
                style: GoogleFonts.plusJakartaSans(
                  color: role.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(2), child: content),
      ),
    );
  }
}
