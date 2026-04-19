import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../courses/models/course_section.dart';

/// Reusable tile for a professor's or student's course section.
/// Tapping navigates to the course detail / course management screen.
class CourseSectionTile extends StatelessWidget {
  const CourseSectionTile({
    required this.section,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final CourseSection section;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final course = section.course;
    final title = course?.title ?? 'Course';
    final code = course?.code ?? '';

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: Radii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.card,
        child: Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            borderRadius: Radii.card,
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: Radii.button,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_book_outlined,
                  color: colors.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (code.isNotEmpty)
                      Text(
                        code,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${section.term} \u00b7 Section ${section.sectionCode}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
