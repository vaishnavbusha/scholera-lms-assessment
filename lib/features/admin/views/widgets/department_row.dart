import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../models/department_with_professors.dart';

/// A single department row used in the admin dashboard's department list.
/// Tapping opens the department detail screen.
class DepartmentRow extends StatelessWidget {
  const DepartmentRow({
    required this.data,
    required this.onTap,
    super.key,
  });

  final DepartmentWithProfessors data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final professorCount = data.professors.length;

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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: Radii.button,
                ),
                child: Icon(
                  Icons.domain_outlined,
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
                      data.department.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      professorCount == 1
                          ? '1 professor'
                          : '$professorCount professors',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
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
