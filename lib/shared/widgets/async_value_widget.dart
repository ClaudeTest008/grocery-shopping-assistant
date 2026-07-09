import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_view.dart';
import 'loading_skeleton.dart';

/// Standard AsyncValue renderer: skeleton while loading, retryable error
/// view on failure.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.skeleton,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => skeleton ?? const ListSkeleton(),
      error: (e, _) => ErrorView(error: e, onRetry: onRetry),
    );
  }
}
