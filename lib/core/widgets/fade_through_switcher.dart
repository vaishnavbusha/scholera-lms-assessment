import 'package:flutter/material.dart';

/// Shared "fade-through" animated switch used wherever the app swaps one
/// widget for another (loader → data, empty → populated, toggle visible →
/// hidden, etc.).
///
/// Difference from a plain [AnimatedSwitcher]: the outgoing widget fades
/// out during the first 45% of the cycle, then the incoming widget fades
/// in during the last 55%. This eliminates the muddy 50%-opacity-of-both
/// frame that makes default crossfades look janky, especially when the
/// two children have different shapes (e.g. shimmer skeleton vs real
/// content cards).
///
/// Pair [child] with a unique [Key] for each distinct state, otherwise
/// AnimatedSwitcher can't tell that the content actually changed.
class FadeThroughSwitcher extends StatelessWidget {
  const FadeThroughSwitcher({
    required this.child,
    this.duration = const Duration(milliseconds: 380),
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: duration,
      // 0..0.45 = outgoing fades out; 0.45..1.0 = incoming fades in.
      switchInCurve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      switchOutCurve: const Interval(0.0, 0.55, curve: Curves.easeInCubic),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: child,
    );
  }
}
