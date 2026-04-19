import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/tokens.dart';

/// Roadmap coverage / progress status. Maps to `progress_status` enum values
/// from the database: `not_started`, `in_progress`, `complete`.
enum ProgressStatus {
  notStarted,
  inProgress,
  complete;

  static ProgressStatus fromDatabase(String value) {
    return switch (value) {
      'not_started' => ProgressStatus.notStarted,
      'in_progress' => ProgressStatus.inProgress,
      'complete' => ProgressStatus.complete,
      _ => ProgressStatus.notStarted,
    };
  }

  String get databaseValue {
    return switch (this) {
      ProgressStatus.notStarted => 'not_started',
      ProgressStatus.inProgress => 'in_progress',
      ProgressStatus.complete => 'complete',
    };
  }

  String get label {
    return switch (this) {
      ProgressStatus.notStarted => 'Not started',
      ProgressStatus.inProgress => 'In progress',
      ProgressStatus.complete => 'Complete',
    };
  }

  Color get _color {
    return switch (this) {
      ProgressStatus.notStarted => Palette.statusNotStarted,
      ProgressStatus.inProgress => Palette.statusInProgress,
      ProgressStatus.complete => Palette.statusComplete,
    };
  }
}

/// Small colored dot + label. The dot carries the status; the label reinforces
/// it for accessibility. Sits inside lists, cards, and row headers without
/// dominating the visual.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.status,
    this.dense = false,
    this.label,
    super.key,
  });

  final ProgressStatus status;

  /// Overrides the default label if you want a custom string (e.g. "Your
  /// progress: Complete"). Defaults to [ProgressStatus.label].
  final String? label;

  /// Dense variant — smaller dot + label for tight rows.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = status._color;
    final displayLabel = label ?? status.label;
    final dotSize = dense ? 7.0 : 9.0;
    final fontSize = dense ? 11.0 : 12.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: Radii.pill,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? Spacing.sm : Spacing.md,
          vertical: dense ? 4 : Spacing.xs + 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: dense ? Spacing.xs : Spacing.sm),
            Text(
              displayLabel,
              style: GoogleFonts.plusJakartaSans(
                color: _darker(color),
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _darker(Color base) {
    final hsl = HSLColor.fromColor(base);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }
}
