import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../data/repositories/module_repository.dart';
import '../../../modules/controllers/module_providers.dart';
import '../../../modules/models/module_item_type.dart';

/// Add an item to a module. Three creatable types: link, note, file.
/// Type picker at the top; the form fields change based on selection.
class CreateModuleItemSheet extends ConsumerStatefulWidget {
  const CreateModuleItemSheet({
    required this.moduleId,
    required this.sectionId,
    required this.moduleTitle,
    super.key,
  });

  final String moduleId;
  final String sectionId;
  final String moduleTitle;

  static Future<void> show(
    BuildContext context, {
    required String moduleId,
    required String sectionId,
    required String moduleTitle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
      builder: (_) => CreateModuleItemSheet(
        moduleId: moduleId,
        sectionId: sectionId,
        moduleTitle: moduleTitle,
      ),
    );
  }

  @override
  ConsumerState<CreateModuleItemSheet> createState() =>
      _CreateModuleItemSheetState();
}

class _CreateModuleItemSheetState
    extends ConsumerState<CreateModuleItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _bodyController = TextEditingController();

  ModuleItemType _type = ModuleItemType.link;
  PlatformFile? _pickedFile;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'ppt', 'pptx'],
        withData: true,
      );
      if (result == null) return;
      setState(() => _pickedFile = result.files.first);
    } catch (e) {
      setState(() => _error = 'Could not open the file picker: $e');
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_type == ModuleItemType.file && _pickedFile?.bytes == null) {
      setState(() => _error = 'Pick a PDF or PPT first.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(moduleRepositoryProvider).createItem(
            moduleId: widget.moduleId,
            sectionId: widget.sectionId,
            title: _titleController.text.trim(),
            type: _type,
            url: _type == ModuleItemType.link
                ? _urlController.text.trim()
                : null,
            body: _type == ModuleItemType.note
                ? _bodyController.text.trim()
                : null,
            fileBytes:
                _type == ModuleItemType.file ? _pickedFile?.bytes : null,
            fileName: _type == ModuleItemType.file ? _pickedFile?.name : null,
          );
      ref.invalidate(sectionModulesProvider(widget.sectionId));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.xl,
          Spacing.lg,
          Spacing.xl,
          Spacing.xl,
        ),
        child: Form(
          key: _formKey,
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
              Text('Add item', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                'Into \u201c${widget.moduleTitle}\u201d',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              _TypePicker(
                selected: _type,
                onChanged: (next) {
                  setState(() {
                    _type = next;
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: Spacing.lg),
              TextFormField(
                controller: _titleController,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Week 1 lecture slides',
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Enter a title.';
                  return null;
                },
              ),
              const SizedBox(height: Spacing.md),
              if (_type == ModuleItemType.link)
                TextFormField(
                  controller: _urlController,
                  enabled: !_submitting,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://example.com/resource',
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Enter a URL.';
                    final uri = Uri.tryParse(v);
                    if (uri == null ||
                        !uri.hasScheme ||
                        !(uri.scheme == 'http' || uri.scheme == 'https')) {
                      return 'Enter a valid http or https URL.';
                    }
                    return null;
                  },
                ),
              if (_type == ModuleItemType.note)
                TextFormField(
                  controller: _bodyController,
                  enabled: !_submitting,
                  minLines: 4,
                  maxLines: 8,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    hintText: 'Plain text the class should see.',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Write something.';
                    return null;
                  },
                ),
              if (_type == ModuleItemType.file)
                _FilePickerField(
                  file: _pickedFile,
                  onPick: _submitting ? null : _pickFile,
                ),
              if (_error != null) ...[
                const SizedBox(height: Spacing.md),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: Spacing.xl),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypePicker extends StatelessWidget {
  const _TypePicker({required this.selected, required this.onChanged});

  final ModuleItemType selected;
  final ValueChanged<ModuleItemType> onChanged;

  static const _options = [
    ModuleItemType.link,
    ModuleItemType.note,
    ModuleItemType.file,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      spacing: Spacing.sm,
      children: [
        for (final type in _options)
          _TypeChip(
            type: type,
            selected: selected == type,
            onTap: () => onChanged(type),
            colors: colors,
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  final ModuleItemType type;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = selected ? colors.primary : colors.surface;
    final foreground = selected ? colors.onPrimary : colors.onSurface;
    final border = selected ? colors.primary : colors.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: Radii.pill,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: Radii.pill,
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, color: foreground, size: 16),
            const SizedBox(width: Spacing.xs),
            Text(
              type.label,
              style: theme.textTheme.labelLarge?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilePickerField extends StatelessWidget {
  const _FilePickerField({required this.file, required this.onPick});

  final PlatformFile? file;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasFile = file != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: Radii.card,
        border: Border.all(
          color: hasFile ? colors.primary : colors.outline,
          width: hasFile ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.picture_as_pdf_outlined,
                  color: colors.onPrimaryContainer,
                  size: 18,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: hasFile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file!.name,
                            style: theme.textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatSize(file!.size),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      )
                    : Text(
                        'PDF or PPT',
                        style: theme.textTheme.bodyMedium,
                      ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: Icon(hasFile ? Icons.refresh : Icons.upload_file, size: 18),
              label: Text(hasFile ? 'Replace file' : 'Pick a file'),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}
