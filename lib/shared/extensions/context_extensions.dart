import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  bool get isTablet => MediaQuery.sizeOf(this).shortestSide >= 600;

  /// True once there is room for a two-pane layout (large tablet,
  /// desktop window, landscape foldable).
  bool get isWide => MediaQuery.sizeOf(this).width >= 900;

  void showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? colors.error : null,
        ),
      );
  }

  /// Gmail-style undo. The row is already gone from the UI; this gives
  /// the user a few seconds to put it back, which is far less punishing
  /// than a confirmation dialog on every swipe.
  ///
  /// Use for cheap, reversible deletions. For something expensive to
  /// reconstruct (a whole list), ask for confirmation up front instead.
  void showUndoSnack(String message, {required VoidCallback onUndo}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              Haptics.selection();
              onUndo();
            },
          ),
        ),
      );
  }
}

/// Thin wrapper so call sites stay readable and haptics can be tuned or
/// disabled in one place. No-ops on platforms without a vibrator.
abstract final class Haptics {
  /// Item checked off, undo tapped, filter toggled.
  static void selection() => HapticFeedback.selectionClick();

  /// Something was removed.
  static void light() => HapticFeedback.lightImpact();

  /// A result landed that the user was waiting for — optimizer finished,
  /// receipt saved.
  static void success() => HapticFeedback.mediumImpact();
}
