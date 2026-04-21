import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../data/repositories/module_repository.dart';
import '../../../modules/controllers/module_providers.dart';

class CreateModuleSheet extends ConsumerStatefulWidget {
  const CreateModuleSheet({required this.sectionId, super.key});

  final String sectionId;

  static Future<void> show(
    BuildContext context, {
    required String sectionId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
      builder: (_) => CreateModuleSheet(sectionId: sectionId),
    );
  }

  @override
  ConsumerState<CreateModuleSheet> createState() => _CreateModuleSheetState();
}

class _CreateModuleSheetState extends ConsumerState<CreateModuleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(moduleRepositoryProvider).createModule(
            sectionId: widget.sectionId,
            title: _titleController.text.trim(),
          );
      ref.invalidate(sectionModulesProvider(widget.sectionId));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Module created')),
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
              Text('New module', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                'Think week-sized. You can add items inside after it\u2019s created.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              TextFormField(
                controller: _titleController,
                enabled: !_submitting,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Module title',
                  hintText: 'Week 1 — Foundations',
                ),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Enter a title.';
                  if (v.length > 120) return 'Keep titles under 120 chars.';
                  return null;
                },
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
                    : const Text('Create module'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
