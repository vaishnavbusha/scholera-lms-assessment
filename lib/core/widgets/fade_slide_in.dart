import 'package:flutter/material.dart';

/// Plays a one-shot fade + spring-settled slide on first build. Used to give
/// list items a lively entrance instead of popping in.
///
/// The slide uses [Curves.easeOutBack] so cards slightly overshoot and
/// settle — the "natural spring" motion without the complexity of a real
/// [SpringSimulation]. The opacity uses [Curves.easeOutCubic] because a
/// back-bounce on alpha reads as a flicker, not a spring.
///
/// [index] staggers the start so a list of items cascades in. Capped at
/// [maxStaggerIndex] so a long list doesn't take forever to settle.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.index = 0,
    this.maxStaggerIndex = 8,
    this.duration = const Duration(milliseconds: 460),
    this.staggerStep = const Duration(milliseconds: 55),
    this.initialOffset = const Offset(0, 0.12),
    super.key,
  });

  final Widget child;
  final int index;
  final int maxStaggerIndex;
  final Duration duration;
  final Duration staggerStep;

  /// Fractional offset (of the widget's size) the child starts at. Default
  /// slides up from 12% below its final position; override with e.g.
  /// `Offset(-0.06, 0)` for a slide-from-left entrance.
  final Offset initialOffset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(
      begin: widget.initialOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    final cappedIndex = widget.index.clamp(0, widget.maxStaggerIndex);
    final delay = widget.staggerStep * cappedIndex;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
