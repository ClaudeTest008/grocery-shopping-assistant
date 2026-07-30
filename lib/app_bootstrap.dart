import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/observability/telemetry.dart';

/// Owns the ProviderScope key so the whole app — every provider, every
/// cached AsyncValue — can be rebuilt from scratch. Used by "Reset demo
/// data" after wiping local storage.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_AppBootstrapState>()?._restart();
  }

  /// Restart without a BuildContext. Needed by flows whose own widget is
  /// unmounted mid-operation — account deletion triggers the router's
  /// sign-out redirect before the flow finishes, so its context dies
  /// under it.
  static void restartGlobal() => _AppBootstrapState._instance?._restart();

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  static _AppBootstrapState? _instance;

  Key _scopeKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  @override
  void dispose() {
    if (identical(_instance, this)) _instance = null;
    super.dispose();
  }

  void _restart() {
    if (mounted) setState(() => _scopeKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: _scopeKey,
      observers: const [TelemetryProviderObserver()],
      child: const GroceryApp(),
    );
  }
}
