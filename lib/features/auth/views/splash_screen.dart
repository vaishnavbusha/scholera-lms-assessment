import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/tokens.dart';

/// Shown during the initial auth resolve on cold start, so the user sees a
/// branded neutral state instead of a fully-drawn login form that gets
/// replaced a moment later (when the cached session is restored and the
/// router redirects to the role home).
///
/// Kept deliberately minimal — a single brand mark centred on the scaffold
/// with a thin progress indicator underneath. No hero, no animation beyond
/// the page transition fade itself.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = 'splash';
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Palette.ink,
                  borderRadius: Radii.card,
                ),
                alignment: Alignment.center,
                child: Text(
                  'S',
                  style: GoogleFonts.plusJakartaSans(
                    color: Palette.paper,
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Scholera',
                style: GoogleFonts.plusJakartaSans(
                  color: Palette.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  height: 1,
                ),
              ),
              const SizedBox(height: Spacing.xxl),
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
