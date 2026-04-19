import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../courses/models/course_section.dart';

/// A professor's course-section row. Shows course code + title, section/term
/// meta underneath. Used on the professor detail screen.
class CourseSectionRow extends StatelessWidget {
  const CourseSectionRow({required this.section, super.key});

  final CourseSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final course = section.course;

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: Radii.card,
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: Radii.button,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book_outlined,
              color: colors.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course == null
                      ? 'Course'
                      : '${course.code} \u00b7 ${course.title}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${section.term} \u00b7 Section ${section.sectionCode}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
