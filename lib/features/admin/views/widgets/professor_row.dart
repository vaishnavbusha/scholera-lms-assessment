import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/tokens.dart';
import '../../../profile/models/app_profile.dart';

/// Profile row reused across admin screens (department detail, future profile
/// list). Shows avatar or initial, display name, optional caption.
class ProfessorRow extends StatelessWidget {
  const ProfessorRow({
    required this.profile,
    this.caption,
    this.onTap,
    super.key,
  });

  final AppProfile profile;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: Radii.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.card,
        child: Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            borderRadius: Radii.card,
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            children: [
              _Avatar(profile: profile),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName.isEmpty
                          ? 'Unnamed'
                          : profile.displayName,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (caption != null && caption!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(caption!, style: theme.textTheme.bodySmall),
                    ] else if (profile.bio.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initial = profile.displayName.isEmpty
        ? '·'
        : profile.displayName[0].toUpperCase();
    final avatarUrl = profile.avatarUrl;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: avatarUrl,
              fit: BoxFit.cover,
              width: 44,
              height: 44,
              errorWidget: (_, __, ___) => _initialLetter(initial, colors),
              placeholder: (_, __) => _initialLetter(initial, colors),
            )
          : _initialLetter(initial, colors),
    );
  }

  Widget _initialLetter(String initial, ColorScheme colors) {
    return Text(
      initial,
      style: GoogleFonts.plusJakartaSans(
        color: colors.onPrimaryContainer,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        height: 1,
      ),
    );
  }
}
