import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../modules/models/module_item.dart';
import '../../../modules/views/module_item_actions.dart';

/// A single module item row. Compact: type icon + title + subtitle with
/// type label, URL host, or file name. Tap opens the item per its type
/// (link → browser, note → reading sheet, file → signed-URL download).
class ModuleItemRow extends ConsumerWidget {
  const ModuleItemRow({required this.item, super.key});

  final ModuleItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final type = item.type;

    return Material(
      color: Colors.transparent,
      borderRadius: Radii.button,
      child: InkWell(
        borderRadius: Radii.button,
        onTap: () => openModuleItem(context, ref, item),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.sm,
            horizontal: Spacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: Radii.button,
                ),
                child: Icon(
                  type.icon,
                  color: colors.onPrimaryContainer,
                  size: 18,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(item),
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(
                Icons.chevron_right,
                color: colors.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _subtitle(ModuleItem item) {
    if (item.url != null && item.url!.isNotEmpty) {
      final host = Uri.tryParse(item.url!)?.host;
      return '${item.type.label} \u00b7 ${host ?? item.url}';
    }
    if (item.storagePath != null && item.storagePath!.isNotEmpty) {
      final segments = item.storagePath!.split('/');
      return '${item.type.label} \u00b7 ${segments.last}';
    }
    if (item.body != null && item.body!.isNotEmpty) {
      return '${item.type.label} \u00b7 ${item.body}';
    }
    return item.type.label;
  }
}
