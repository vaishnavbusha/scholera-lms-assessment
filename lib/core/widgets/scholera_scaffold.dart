import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import 'role_badge.dart';

/// The common page scaffold. Every screen in the app sits inside one of
/// these so spacing, app bar, and surface treatment stay consistent.
///
/// Two layout modes:
/// * [ScholeraScaffold.list] — wraps content in a padded ListView (the
///   default for most form / list screens).
/// * [ScholeraScaffold.custom] — passes [body] through untouched (used when
///   a screen needs full control over scroll: CustomScrollView, NestedScroll,
///   tab views, etc.).
class ScholeraScaffold extends StatelessWidget {
  const ScholeraScaffold._({
    required this.title,
    this.subtitle,
    this.actions,
    this.showRoleBadge = false,
    this.onRoleBadgeTap,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.children,
    this.body,
    super.key,
  });

  factory ScholeraScaffold.list({
    Key? key,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    bool showRoleBadge = false,
    VoidCallback? onRoleBadgeTap,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    required List<Widget> children,
  }) {
    return ScholeraScaffold._(
      key: key,
      title: title,
      subtitle: subtitle,
      actions: actions,
      showRoleBadge: showRoleBadge,
      onRoleBadgeTap: onRoleBadgeTap,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      children: children,
    );
  }

  factory ScholeraScaffold.custom({
    Key? key,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    bool showRoleBadge = false,
    VoidCallback? onRoleBadgeTap,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    required Widget body,
  }) {
    return ScholeraScaffold._(
      key: key,
      title: title,
      subtitle: subtitle,
      actions: actions,
      showRoleBadge: showRoleBadge,
      onRoleBadgeTap: onRoleBadgeTap,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: body,
    );
  }

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showRoleBadge;
  final VoidCallback? onRoleBadgeTap;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? children;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Spacing.lg,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.appBarTheme.titleTextStyle),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (showRoleBadge)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.lg),
              child: RoleBadge(onTap: onRoleBadgeTap),
            ),
          if (actions != null) ...actions!,
        ],
      ),
      body: SafeArea(
        top: false,
        child: body ??
            ListView(padding: Spacing.screenPadding, children: children ?? []),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
