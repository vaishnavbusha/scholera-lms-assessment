import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import 'loading_skeleton.dart';

/// Skeleton placeholder for a course shell while the section metadata is
/// loading. Matches the real shell's app bar + tab bar + body footprint so
/// there's no layout shift when the data resolves.
class CourseShellSkeleton extends StatelessWidget {
  const CourseShellSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64 + kTextTabBarHeight),
        child: AppBar(
          titleSpacing: Spacing.lg,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              LoadingSkeletonBar(width: 180, height: 18),
              SizedBox(height: 6),
              LoadingSkeletonBar(width: 120, height: 11),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Container(
              height: kTextTabBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final label in const [
                    'Announcements',
                    'Modules',
                    'Roadmap',
                  ])
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: const LoadingSkeletonList(count: 3),
    );
  }
}
