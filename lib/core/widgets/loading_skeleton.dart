import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/tokens.dart';

/// A single shimmer bar — the atom of any skeleton.
class LoadingSkeletonBar extends StatelessWidget {
  const LoadingSkeletonBar({
    this.width,
    this.height = 14,
    this.radius = 6,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Palette.outline,
      highlightColor: Palette.paper,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Palette.outline,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A row-style skeleton item: circle + two stacked bars.
class LoadingSkeletonCard extends StatelessWidget {
  const LoadingSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Spacing.cardPadding,
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: Radii.card,
        border: Border.all(color: Palette.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Palette.outline,
            highlightColor: Palette.paper,
            period: const Duration(milliseconds: 1400),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Palette.outline,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LoadingSkeletonBar(width: 160, height: 14),
                SizedBox(height: Spacing.sm),
                LoadingSkeletonBar(width: 220, height: 12),
                SizedBox(height: Spacing.xs),
                LoadingSkeletonBar(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A stack of skeleton cards — the default loading state for list screens.
class LoadingSkeletonList extends StatelessWidget {
  const LoadingSkeletonList({this.count = 4, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: Spacing.screenPadding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
      itemBuilder: (_, __) => const LoadingSkeletonCard(),
    );
  }
}
