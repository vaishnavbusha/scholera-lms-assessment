import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../data/repositories/announcement_repository.dart';
import '../../../announcements/controllers/announcement_providers.dart';
import '../../../auth/controllers/current_profile_provider.dart';

/// Bottom sheet for creating a new announcement. Self-contained: owns its
/// own form state, submits through the repository, invalidates the section
/// announcements provider on success so the list refreshes automatically.
class CreateAnnouncementSheet extends ConsumerStatefulWidget {
  const CreateAnnouncementSheet({required this.sectionId, super.key});

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
      builder: (_) => CreateAnnouncementSheet(sectionId: sectionId),
    );
  }

  @override
  ConsumerState<CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState
    extends ConsumerState<CreateAnnouncementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final professor = ref.read(currentProfileProvider);
      await ref.read(announcementRepositoryProvider).create(
        sectionId: widget.sectionId,
        professorId: professor.id,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
      ref.invalidate(sectionAnnouncementsProvider(widget.sectionId));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement posted')),
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
              Text('New announcement', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                'Students in this section will see it in the course detail.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              TextFormField(
                controller: _titleController,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Office hours moved',
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Enter a title.';
                  if (v.length > 120) return 'Keep titles under 120 chars.';
                  return null;
                },
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _bodyController,
                enabled: !_submitting,
                minLines: 4,
                maxLines: 8,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  hintText: 'What do students need to know?',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Write something.';
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
                    : const Text('Post announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
