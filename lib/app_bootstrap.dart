import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Owns the ProviderScope key so the whole app — every provider, every
/// cached AsyncValue — can be rebuilt from scratch. Used by "Reset demo
/// data" after wiping local storage.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_AppBootstrapState>()?._restart();
  }

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  Key _scopeKey = UniqueKey();

  void _restart() => setState(() => _scopeKey = UniqueKey());

  @override
  Widget build(BuildContext context) {
    return ProviderScope(key: _scopeKey, child: const GroceryApp());
  }
}
