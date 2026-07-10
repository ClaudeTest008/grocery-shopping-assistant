import 'package:flutter_riverpod/legacy.dart';

import '../../shopping_lists/domain/basket_optimizer.dart';

/// Trip overlay pushed onto the map from the basket optimizer:
/// the full result (so the map can compare options) plus the index of
/// the option currently shown.
final tripOverlayProvider = StateProvider<TripOverlay?>((_) => null);

class TripOverlay {
  const TripOverlay({required this.result, required this.selectedIndex});

  final OptimizationResult result;
  final int selectedIndex;

  BasketOption get selected => result.options[selectedIndex];

  TripOverlay withIndex(int index) =>
      TripOverlay(result: result, selectedIndex: index);
}
