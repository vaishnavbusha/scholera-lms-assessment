import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_state.dart';
import 'loading_skeleton.dart';

/// Renders a typed [AsyncValue] into one of three mutually exclusive visual
/// states: loading, error, data. Keeps every screen consistent so we don't
/// reinvent the spinner-vs-skeleton vs-error question on every feature.
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
    return value.when(
      data: data,
      loading: () => loading?.call(context) ?? const LoadingSkeletonList(),
      error: (err, stack) =>
          error?.call(err, stack) ??
          ErrorState(
            title: errorTitle,
            message: err.toString(),
            onRetry: onRetry,
          ),
    );
  }
}
