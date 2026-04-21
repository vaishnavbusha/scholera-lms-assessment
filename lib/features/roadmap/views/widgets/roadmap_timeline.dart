import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../models/roadmap_item.dart';
import '../../models/roadmap_module.dart';
import 'roadmap_item_card.dart';

/// Timeline-tree layout of the roadmap: one continuous vertical spine runs
/// down the left, module nodes branch off as larger dots, items hang below
/// each module as smaller dots. Reused by both professor and student views
/// — the caller wires pickers in by passing change callbacks.
class RoadmapTimeline extends StatelessWidget {
  const RoadmapTimeline({
    required this.modules,
    this.onProfessorStatusChanged,
    this.onStudentStatusChanged,
    super.key,
  });

  final List<RoadmapModule> modules;
  final void Function(String itemId, ProgressStatus status)?
  onProfessorStatusChanged;
  final void Function(String itemId, ProgressStatus status)?
  onStudentStatusChanged;

  List<_Entry> _flatten() {
    final entries = <_Entry>[];
    for (final module in modules) {
      entries.add(_ModuleEntry(module));
      for (final item in module.items) {
        entries.add(_ItemEntry(item));
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _flatten();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(
            entry: entries[i],
            isFirst: i == 0,
            isLast: i == entries.length - 1,
            onProfessorStatusChanged: onProfessorStatusChanged,
            onStudentStatusChanged: onStudentStatusChanged,
          ),
      ],
    );
  }
}

/// One row in the timeline. Composed of a spine column (line + node) and a
/// content column (module header or item card). Intrinsic height so the
/// line segments stretch to match the content's natural height.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.onProfessorStatusChanged,
    required this.onStudentStatusChanged,
  });

  final _Entry entry;
  final bool isFirst;
  final bool isLast;
  final void Function(String itemId, ProgressStatus status)?
  onProfessorStatusChanged;
  final void Function(String itemId, ProgressStatus status)?
  onStudentStatusChanged;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Spine(
            isFirst: isFirst,
            isLast: isLast,
            isModule: entry is _ModuleEntry,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: entry is _ModuleEntry ? Spacing.md : Spacing.lg,
                top: entry is _ModuleEntry && !isFirst ? Spacing.md : 0,
              ),
              child: entry.build(
                context,
                onProfessorStatusChanged: onProfessorStatusChanged,
                onStudentStatusChanged: onStudentStatusChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Spine column: draws the vertical line (with top/bottom segments gated by
/// isFirst/isLast) and the node dot at a fixed vertical offset so the dot
/// aligns with the content's first visible line.
class _Spine extends StatelessWidget {
  const _Spine({
    required this.isFirst,
    required this.isLast,
    required this.isModule,
  });

  final bool isFirst;
  final bool isLast;
  final bool isModule;

  static const double _columnWidth = 40;
  static const double _lineX = 19;
  static const double _moduleDotSize = 14;
  static const double _itemDotSize = 10;
  static const double _dotTop = 14;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lineColor = colors.primary.withValues(alpha: 0.25);
    final dotSize = isModule ? _moduleDotSize : _itemDotSize;
    final dotCenterY = _dotTop + dotSize / 2;

    return SizedBox(
      width: _columnWidth,
      child: Stack(
        children: [
          // Line above the node.
          if (!isFirst)
            Positioned(
              top: 0,
              left: _lineX,
              height: dotCenterY,
              child: Container(width: 2, color: lineColor),
            ),
          // Line below the node.
          if (!isLast)
            Positioned(
              top: dotCenterY,
              bottom: 0,
              left: _lineX,
              child: Container(width: 2, color: lineColor),
            ),
          // Node.
          Positioned(
            top: _dotTop,
            left: (_columnWidth - dotSize) / 2,
            child: _Node(isModule: isModule),
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.isModule});

  final bool isModule;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = isModule ? _Spine._moduleDotSize : _Spine._itemDotSize;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isModule ? colors.primary : colors.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary, width: 2),
      ),
    );
  }
}

// ---- Entry models -----------------------------------------------------------

abstract class _Entry {
  Widget build(
    BuildContext context, {
    void Function(String itemId, ProgressStatus status)?
    onProfessorStatusChanged,
    void Function(String itemId, ProgressStatus status)?
    onStudentStatusChanged,
  });
}

class _ModuleEntry extends _Entry {
  _ModuleEntry(this.module);

  final RoadmapModule module;

  @override
  Widget build(
    BuildContext context, {
    void Function(String itemId, ProgressStatus status)?
    onProfessorStatusChanged,
    void Function(String itemId, ProgressStatus status)?
    onStudentStatusChanged,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Module ${module.position + 1}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(module.title, style: theme.textTheme.titleLarge),
        if (module.items.isEmpty) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            'No items yet.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ItemEntry extends _Entry {
  _ItemEntry(this.item);

  final RoadmapItem item;

  @override
  Widget build(
    BuildContext context, {
    void Function(String itemId, ProgressStatus status)?
    onProfessorStatusChanged,
    void Function(String itemId, ProgressStatus status)?
    onStudentStatusChanged,
  }) {
    return RoadmapItemCard(
      item: item,
      onProfessorStatusChanged: onProfessorStatusChanged == null
          ? null
          : (status) => onProfessorStatusChanged(item.id, status),
      onStudentStatusChanged: onStudentStatusChanged == null
          ? null
          : (status) => onStudentStatusChanged(item.id, status),
    );
  }
}
