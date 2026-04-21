import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/tokens.dart';
import '../../../data/repositories/module_repository.dart';
import '../models/module_item.dart';
import '../models/module_item_type.dart';

/// Dispatches a tap on a module item to the right destination:
/// - [ModuleItemType.link] opens the URL in the external browser
/// - [ModuleItemType.note] opens a modal sheet with the full note body
/// - [ModuleItemType.file] resolves a short-lived signed URL and launches it
///
/// Used from both professor and student module views.
Future<void> openModuleItem(
  BuildContext context,
  WidgetRef ref,
  ModuleItem item,
) async {
  switch (item.type) {
    case ModuleItemType.link:
    case ModuleItemType.video:
      await _launchUrl(context, item.url);
      return;
    case ModuleItemType.note:
      await _showNoteSheet(context, item);
      return;
    case ModuleItemType.file:
    case ModuleItemType.lecture:
      await _openStoredFile(context, ref, item);
      return;
  }
}

Future<void> _launchUrl(BuildContext context, String? rawUrl) async {
  final trimmed = rawUrl?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    _showSnack(context, 'This item has no URL attached.');
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

Future<void> _showNoteSheet(BuildContext context, ModuleItem item) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
    builder: (context) {
      final theme = Theme.of(context);
      return Padding(
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
                  color: theme.colorScheme.outline,
                  borderRadius: Radii.pill,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(item.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Spacing.xs),
            Text(
              'Note',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: Spacing.md),
            SingleChildScrollView(
              child: Text(
                (item.body ?? '').trim().isEmpty
                    ? 'This note is empty.'
                    : item.body!,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _openStoredFile(
  BuildContext context,
  WidgetRef ref,
  ModuleItem item,
) async {
  final path = item.storagePath;
  if (path == null || path.isEmpty) {
    _showSnack(context, 'This item has no file attached.');
    return;
  }
  try {
    final signedUrl =
        await ref.read(moduleRepositoryProvider).createSignedUrlFor(path);
    if (!context.mounted) return;
    final launched = await launchUrl(
      Uri.parse(signedUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showSnack(context, 'Couldn\u2019t open that file.');
    }
  } catch (e) {
    if (context.mounted) {
      _showSnack(context, 'Couldn\u2019t open that file: $e');
    }
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
