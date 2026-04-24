import 'package:flutter/material.dart';

/// Scholera's page transition: a plain cross-fade.
///
/// Intentionally boring and cheap — no slide, no scale, no parallax. Slides
/// and scales both force the GPU to composite two full-screen bitmaps per
/// frame; a fade only needs alpha blending, which is effectively free even
/// at 120Hz while the destination screen is still rendering its skeleton.
class ScholeraPageTransitionsBuilder extends PageTransitionsBuilder {
  const ScholeraPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }
}
