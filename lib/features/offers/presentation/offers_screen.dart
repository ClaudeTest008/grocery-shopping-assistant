import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../stores/data/store_repositories.dart';
import '../../stores/domain/store.dart';
import '../data/offer_repositories.dart';
import '../domain/offer.dart';

IconData _offerIcon(OfferType type) => switch (type) {
  OfferType.weeklyAd => Icons.newspaper_outlined,
  OfferType.bogo => Icons.percent_outlined,
  OfferType.cashback => Icons.savings_outlined,
  OfferType.loyalty => Icons.card_giftcard_outlined,
  OfferType.discount => Icons.local_offer_outlined,
};

String? _discountBadge(Offer offer) {
  if (offer.discountPercent != null) {
    return '${offer.discountPercent!.toStringAsFixed(0)}% off';
  }
  if (offer.discountAmount != null) {
    return '${Formatters.currency(offer.discountAmount!)} off';
  }
  return null;
}

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(activeOffersProvider);
    final storesAsync = ref.watch(nearbyStoresProvider);
    final storeNames = <String, String>{
      for (final s in storesAsync.value ?? const <Store>[]) s.id: s.name,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: AsyncValueWidget<List<Offer>>(
        value: offersAsync,
        onRetry: () => ref.invalidate(activeOffersProvider),
        data: (offers) {
          if (offers.isEmpty) {
            return const EmptyState(
              icon: Icons.local_offer_outlined,
              title: 'No active offers',
              message: 'Check back later for new deals.',
            );
          }
          final byStore = <String, List<Offer>>{};
          for (final offer in offers) {
            byStore.putIfAbsent(offer.storeId, () => []).add(offer);
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              for (final entry in byStore.entries) ...[
                SectionHeader(title: storeNames[entry.key] ?? entry.key),
                for (final offer in entry.value) _OfferCard(offer: offer),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badge = _discountBadge(offer);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_offerIcon(offer.type), color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (offer.description != null)
                    Text(
                      offer.description!,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (badge != null)
                        Chip(
                          label: Text(badge),
                          backgroundColor: colors.primaryContainer,
                          labelStyle: TextStyle(
                            color: colors.onPrimaryContainer,
                          ),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        ),
                      if (offer.expiresSoon)
                        Chip(
                          label: const Text('Ending soon'),
                          backgroundColor: colors.errorContainer,
                          labelStyle: TextStyle(color: colors.onErrorContainer),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        )
                      else
                        Text(
                          'Ends ${Formatters.relativeDays(offer.validTo)}',
                          style: context.text.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
