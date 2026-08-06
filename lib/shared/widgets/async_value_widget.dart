import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_view.dart';
import 'loading_skeleton.dart';

/// Standard AsyncValue renderer: skeleton while loading, retryable error
/// view on failure. A failed refetch with stale data available keeps the
/// data on screen behind a slim retry banner — offline users must never
/// watch the list they were working with vanish.
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
    if (value.hasError && value.hasValue) {
      // `as T` not `!`: T may itself be nullable (e.g. Product?).
      final stale = data(value.value as T);
      // This widget lives both in bounded slots (Expanded body) and in
      // shrink-wrapped ListView children, so the flex fit must follow
      // the incoming constraints.
      return LayoutBuilder(
        builder: (context, constraints) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StaleBanner(onRetry: onRetry),
            if (constraints.hasBoundedHeight) Expanded(child: stale) else stale,
          ],
        ),
      );
    }
    return value.when(
      data: data,
      loading: () => skeleton ?? const ListSkeleton(),
      error: (e, _) => ErrorView(error: e, onRetry: onRetry),
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Showing saved data',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
