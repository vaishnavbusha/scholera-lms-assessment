import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/tokens.dart';
import '../models/module_item.dart';
import '../models/module_item_type.dart';

/// Dispatches a tap on a module item to the right destination:
/// - [ModuleItemType.link] opens the URL in the external browser
/// - Every other type (note, file, lecture, video) surfaces an in-app sheet
///   with the item's details — no browser launch for non-link types, to
///   keep the user inside the app unless they explicitly chose a web link
Future<void> openModuleItem(
  BuildContext context,
  WidgetRef ref,
  ModuleItem item,
) async {
  switch (item.type) {
    case ModuleItemType.link:
      await _launchUrl(context, item.url);
      return;
    case ModuleItemType.note:
    case ModuleItemType.file:
    case ModuleItemType.lecture:
    case ModuleItemType.video:
      await _showItemSheet(context, item);
      return;
  }
}

Future<void> _launchUrl(BuildContext context, String? rawUrl) async {
  final trimmed = rawUrl?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    _showSnack(context, 'This link is empty.');
    return;
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme) {
    _showSnack(context, 'That link doesn\u2019t look valid.');
    return;
  }
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    _showSnack(context, 'Couldn\u2019t open that link.');
  }
}

/// Shows an in-app bottom sheet for a non-link item. Renders different
/// content depending on the item type:
/// - note: the full body text, scrollable
/// - file / lecture: the stored filename, for now surfaced as info only
/// - video: falls back to info view (no video item is creatable in the UI)
Future<void> _showItemSheet(BuildContext context, ModuleItem item) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
    builder: (context) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.xl,
          Spacing.lg,
          Spacing.xl,
          Spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: Radii.pill,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: Radii.button,
                  ),
                  child: Icon(
                    item.type.icon,
                    color: colors.onPrimaryContainer,
                    size: 18,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.type.label, style: theme.textTheme.labelSmall),
                      const SizedBox(height: 2),
                      Text(
                        item.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            _SheetBody(item: item),
          ],
        ),
      );
    },
  );
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.item});

  final ModuleItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    switch (item.type) {
      case ModuleItemType.note:
        final body = (item.body ?? '').trim();
        return SingleChildScrollView(
          child: Text(
            body.isEmpty ? 'This note is empty.' : body,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        );
      case ModuleItemType.file:
      case ModuleItemType.lecture:
        final fileName = _fileNameFrom(item.storagePath);
        return Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: Radii.card,
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: colors.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  fileName ?? 'Attached file',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      case ModuleItemType.video:
        return Text(
          item.url ?? 'Video reference',
          style: theme.textTheme.bodyMedium,
        );
      case ModuleItemType.link:
        return const SizedBox.shrink();
    }
  }

  static String? _fileNameFrom(String? storagePath) {
    if (storagePath == null || storagePath.isEmpty) return null;
    final segments = storagePath.split('/');
    if (segments.isEmpty) return null;
    return segments.last;
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
