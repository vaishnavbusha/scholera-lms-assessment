import 'package:flutter/widgets.dart';

/// Spacing scale. Use these everywhere — no raw magic numbers in layouts.
///
/// The scale is deliberately narrow (8px-based plus a tight 4 and a roomy 32)
/// to keep screens rhythmically consistent.
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
}

/// Border radius scale.
abstract final class Radii {
  static const Radius xs = Radius.circular(4);
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(24);

  static const BorderRadius button = BorderRadius.all(sm);
  static const BorderRadius input = BorderRadius.all(sm);
  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius sheet = BorderRadius.vertical(top: lg);
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

/// Elevation. Kept flat-ish — shadows are restrained in the academic workshop.
abstract final class Elevation {
  static const double none = 0;
  static const double subtle = 1;
  static const double raised = 3;
  static const double popover = 6;
}

/// Animation durations. Mobile wants these tighter than web.
abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration smooth = Duration(milliseconds: 320);
  static const Duration deliberate = Duration(milliseconds: 480);

  static const Duration listStagger = Duration(milliseconds: 40);
}
