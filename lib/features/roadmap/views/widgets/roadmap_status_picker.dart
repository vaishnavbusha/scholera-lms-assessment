import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/status_pill.dart';

/// A StatusPill that opens a popup when tapped, letting the user pick a new
/// [ProgressStatus]. Shared between professor coverage toggle and student
/// progress toggle.
class RoadmapStatusPicker extends StatelessWidget {
  const RoadmapStatusPicker({
    required this.status,
    required this.onChanged,
    this.label,
    super.key,
  });

  final ProgressStatus status;
  final ValueChanged<ProgressStatus> onChanged;

  /// Optional label prefix shown before the pill, e.g. "Coverage" or "You".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _pickStatus(context),
      borderRadius: Radii.pill,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                '$label:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: Spacing.xs),
            ],
            StatusPill(status: status, dense: true),
            const SizedBox(width: 2),
            Icon(
              Icons.unfold_more,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStatus(BuildContext context) async {
    final choice = await showModalBottomSheet<ProgressStatus>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.xl,
              Spacing.lg,
              Spacing.xl,
              Spacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: Radii.pill,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Text(
                  'Change status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: Spacing.md),
                for (final option in ProgressStatus.values) ...[
                  _StatusOption(
                    status: option,
                    selected: option == status,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
                  if (option != ProgressStatus.values.last)
                    const SizedBox(height: Spacing.sm),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (choice != null && choice != status) {
      onChanged(choice);
    }
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final ProgressStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      borderRadius: Radii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.card,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: Radii.card,
            border: Border.all(
              color: selected ? colors.primary : colors.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              StatusPill(status: status),
              const Spacer(),
              if (selected)
                Icon(Icons.check, color: colors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
