import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

/// Price display with optional strikethrough original price for deals.
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = 'USD',
    this.large = false,
  });

  final double price;
  final double? originalPrice;
  final String currency;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDeal = originalPrice != null && originalPrice! > price;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          Formatters.currency(price, code: currency),
          style: (large
                  ? theme.textTheme.headlineSmall
                  : theme.textTheme.titleMedium)
              ?.copyWith(
            fontWeight: FontWeight.w800,
            color: hasDeal ? theme.colorScheme.primary : null,
          ),
        ),
        if (hasDeal) ...[
          const SizedBox(width: 6),
          Text(
            Formatters.currency(originalPrice!, code: currency),
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
