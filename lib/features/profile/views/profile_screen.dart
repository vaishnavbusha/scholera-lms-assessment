import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/role_theme_scope.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/scholera_scaffold.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/current_profile_provider.dart';
import '../../auth/models/app_role.dart';

/// Shared profile screen. Any role can view and edit their own display
/// name, bio, and avatar. Avatar upload commits immediately on pick;
/// name/bio commit on Save.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = 'profile';
  static const routePath = '/profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  bool _initialized = false;
  bool _savingFields = false;
  bool _uploadingAvatar = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);

    if (!_initialized) {
      _nameController.text = profile.displayName;
      _bioController.text = profile.bio;
      _initialized = true;
    }

    final role = profile.role;
    final isDirty = _nameController.text.trim() != profile.displayName ||
        _bioController.text.trim() != profile.bio;

    return RoleThemeScope.forAppRole(
      role: role,
      child: ScholeraScaffold.list(
        title: 'Profile',
        subtitle: _subtitleForRole(role),
        showRoleBadge: true,
        children: [
          _AvatarSection(
            profile: profile,
            uploading: _uploadingAvatar,
            onPick: _uploadingAvatar ? null : _pickAvatar,
          ),
          const SizedBox(height: Spacing.xl),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              hintText: 'What should we call you?',
            ),
            textInputAction: TextInputAction.next,
            enabled: !_savingFields,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Spacing.md),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'A short description of yourself.',
              alignLabelWithHint: true,
            ),
            minLines: 3,
            maxLines: 6,
            enabled: !_savingFields,
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null) ...[
            const SizedBox(height: Spacing.md),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: Spacing.xl),
          FilledButton(
            onPressed: (!isDirty || _savingFields) ? null : _saveFields,
            child: _savingFields
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save changes'),
          ),
          const SizedBox(height: Spacing.md),
          OutlinedButton(
            onPressed: _savingFields
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }

  String _subtitleForRole(AppRole role) {
    return switch (role) {
      AppRole.admin => 'Scholera \u00b7 Admin',
      AppRole.professor => 'Scholera \u00b7 Professor',
      AppRole.student => 'Scholera \u00b7 Student',
    };
  }

  Future<void> _saveFields() async {
    final profile = ref.read(currentProfileProvider);
    setState(() {
      _savingFields = true;
      _error = null;
    });
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            id: profile.id,
            displayName: _nameController.text.trim(),
            bio: _bioController.text.trim(),
          );
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _savingFields = false);
    }
  }

  Future<void> _pickAvatar() async {
    final profile = ref.read(currentProfileProvider);
    setState(() {
      _uploadingAvatar = true;
      _error = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        withData: true,
      );
      if (result == null) {
        if (mounted) setState(() => _uploadingAvatar = false);
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        throw StateError('Couldn\u2019t read the picked file.');
      }
      await ref.read(profileRepositoryProvider).uploadAvatar(
            userId: profile.id,
            bytes: bytes,
            fileName: file.name,
          );
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.profile,
    required this.uploading,
    required this.onPick,
  });

  final dynamic profile;
  final bool uploading;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = profile.avatarUrl as String?;
    final displayName = profile.displayName as String;
    final initial = displayName.isEmpty ? '·' : displayName[0].toUpperCase();

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      width: 96,
                      height: 96,
                      errorWidget: (_, __, ___) =>
                          _InitialLetter(letter: initial),
                      placeholder: (_, __) =>
                          _InitialLetter(letter: initial),
                    )
                  : _InitialLetter(letter: initial),
            ),
            if (uploading)
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                ),
                alignment: Alignment.center,
                child: const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            Material(
              color: colors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPick,
                child: const Padding(
                  padding: EdgeInsets.all(Spacing.sm),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          'Tap the camera icon to change your avatar',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InitialLetter extends StatelessWidget {
  const _InitialLetter({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      letter,
      style: GoogleFonts.plusJakartaSans(
        color: colors.onPrimaryContainer,
        fontWeight: FontWeight.w700,
        fontSize: 40,
        height: 1,
      ),
    );
  }
}
