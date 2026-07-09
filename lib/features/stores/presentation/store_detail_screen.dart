import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../offers/data/offer_repositories.dart';
import '../../offers/domain/offer.dart';
import '../data/store_repositories.dart';
import '../domain/store.dart';

final _storeProvider = FutureProvider.family<Store?, String>(
  (ref, id) => ref.watch(storeRepositoryProvider).byId(id),
);

final _storeOffersProvider = FutureProvider.family<List<Offer>, String>(
  (ref, id) => ref.watch(offerRepositoryProvider).activeOffers(storeId: id),
);

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class StoreDetailScreen extends ConsumerWidget {
  const StoreDetailScreen({super.key, required this.storeId});

  final String storeId;

  Future<void> _directions(Store store) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${store.lat},${store.lng}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(String phone) async {
    await launchUrl(Uri.parse('tel:$phone'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(_storeProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: Text(storeAsync.value?.name ?? 'Store')),
      body: AsyncValueWidget<Store?>(
        value: storeAsync,
        onRetry: () => ref.invalidate(_storeProvider(storeId)),
        data: (store) {
          if (store == null) {
            return const Center(child: Text('Store not found'));
          }
          final colors = context.colors;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store.name,
                                style: context.text.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(store.isOpenNow ? 'Open' : 'Closed'),
                              backgroundColor: store.isOpenNow
                                  ? colors.tertiaryContainer
                                  : colors.errorContainer,
                              labelStyle: TextStyle(
                                color: store.isOpenNow
                                    ? colors.onTertiaryContainer
                                    : colors.onErrorContainer,
                              ),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store.address,
                          style: context.text.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (store.distanceKm != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${Formatters.distanceKm(store.distanceKm!)} away',
                            style: context.text.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _directions(store),
                                icon: const Icon(Icons.directions_outlined),
                                label: const Text('Directions'),
                              ),
                            ),
                            if (store.phone != null) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _call(store.phone!),
                                  icon: const Icon(Icons.call_outlined),
                                  label: const Text('Call'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'Opening hours'),
              if (store.openingHours != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      for (var d = 1; d <= 7; d++)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(_weekdayLabels[d - 1]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                store.openingHours!['$d'] == 'closed' ||
                                        store.openingHours!['$d'] == null
                                    ? 'Closed'
                                    : store.openingHours!['$d']!,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SectionHeader(title: "This week's offers"),
              _OffersSection(storeId: storeId),
            ],
          );
        },
      ),
    );
  }
}

class _OffersSection extends ConsumerWidget {
  const _OffersSection({required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(_storeOffersProvider(storeId));
    return AsyncValueWidget<List<Offer>>(
      value: offersAsync,
      onRetry: () => ref.invalidate(_storeOffersProvider(storeId)),
      data: (offers) {
        if (offers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No active offers this week.'),
          );
        }
        return Column(
          children: [
            for (final offer in offers)
              ListTile(
                leading: const Icon(Icons.local_offer_outlined),
                title: Text(offer.title),
                subtitle: offer.description != null
                    ? Text(offer.description!)
                    : null,
                trailing: Text(
                  'Ends ${Formatters.relativeDays(offer.validTo)}',
                  style: context.text.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }
}
