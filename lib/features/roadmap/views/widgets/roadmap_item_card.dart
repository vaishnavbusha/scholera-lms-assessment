import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/topic_chip.dart';
import '../../../lecture_insights/views/lecture_insight_sheet.dart';
import '../../../modules/models/module_item_type.dart';
import '../../models/roadmap_item.dart';
import 'roadmap_status_picker.dart';

/// A single roadmap item: module-item title + type, extracted topics as
/// chips, and coverage + (optional) student progress pickers.
///
/// Reused by both professor and student roadmap views — the student roadmap
/// passes in [onStudentStatusChanged] to surface the student's own picker.
class RoadmapItemCard extends StatelessWidget {
  const RoadmapItemCard({
    required this.item,
    this.onProfessorStatusChanged,
    this.onStudentStatusChanged,
    super.key,
  });

  final RoadmapItem item;

  /// If null, the professor status is shown as read-only.
  final ValueChanged<ProgressStatus>? onProfessorStatusChanged;

  /// If null, the student progress picker is hidden entirely (professor view).
  final ValueChanged<ProgressStatus>? onStudentStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: Radii.card,
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: Radii.button,
                ),
                child: Icon(
                  item.type.icon,
                  color: colors.onPrimaryContainer,
                  size: 16,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(item.type.label, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (_hasInsights(item))
                TextButton.icon(
                  onPressed: () => LectureInsightSheet.show(context, item),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                  label: const Text('Insights'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 4,
                    ),
                  ),
                ),
            ],
          ),
          if (item.topics.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                for (final topic in item.topics)
                  TopicChip(label: topic.title, confidence: topic.confidence),
              ],
            ),
          ],
          const SizedBox(height: Spacing.md),
          const Divider(height: 1),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.lg,
            runSpacing: Spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (onProfessorStatusChanged != null)
                RoadmapStatusPicker(
                  status: item.professorStatus,
                  label: 'Coverage',
                  onChanged: onProfessorStatusChanged!,
                )
              else
                _StatusRow(
                  label: 'Coverage',
                  status: item.professorStatus,
                ),
              if (onStudentStatusChanged != null)
                RoadmapStatusPicker(
                  status: item.studentStatus ?? ProgressStatus.notStarted,
                  label: 'You',
                  onChanged: onStudentStatusChanged!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

bool _hasInsights(RoadmapItem item) {
  if (item.type != ModuleItemType.file && item.type != ModuleItemType.lecture) {
    return false;
  }
  final path = item.storagePath;
  return path != null && path.isNotEmpty;
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.status});

  final String label;
  final ProgressStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: Spacing.xs),
        StatusPill(status: status, dense: true),
      ],
    );
  }
}
