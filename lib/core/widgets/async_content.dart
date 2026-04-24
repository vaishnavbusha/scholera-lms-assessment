import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_state.dart';
import 'fade_through_switcher.dart';
import 'loading_skeleton.dart';

/// Renders a typed [AsyncValue] into one of three mutually exclusive visual
/// states: loading, error, data. Keeps every screen consistent so we don't
/// reinvent the spinner-vs-skeleton-vs-error question on every feature.
///
/// State swaps go through [FadeThroughSwitcher] — the outgoing widget fades
/// out before the incoming fades in, so skeleton → data never looks muddy
/// even when their shapes don't perfectly match.
class AsyncContent<T> extends StatelessWidget {
  const AsyncContent({
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
    this.errorTitle = 'Something went sideways',
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final WidgetBuilder? loading;
  final Widget Function(Object error, StackTrace? stack)? error;
  final VoidCallback? onRetry;
  final String errorTitle;

  @override
  Widget build(BuildContext context) {
    final child = value.when(
      data: (v) => KeyedSubtree(
        key: const ValueKey('async-content-data'),
        child: data(v),
      ),
      loading: () => KeyedSubtree(
        key: const ValueKey('async-content-loading'),
        child: loading?.call(context) ?? const LoadingSkeletonList(),
      ),
      error: (err, stack) => KeyedSubtree(
        key: const ValueKey('async-content-error'),
        child: error?.call(err, stack) ??
            ErrorState(
              title: errorTitle,
              message: err.toString(),
              onRetry: onRetry,
            ),
      ),
    );

    return FadeThroughSwitcher(child: child);
  }
}
