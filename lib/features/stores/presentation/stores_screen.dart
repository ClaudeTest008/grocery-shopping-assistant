import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/store_repositories.dart';
import '../domain/store.dart';

class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(nearbyStoresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Map',
            onPressed: () => context.push('/map'),
          ),
        ],
      ),
      body: AsyncValueWidget<List<Store>>(
        value: storesAsync,
        onRetry: () => ref.invalidate(nearbyStoresProvider),
        data: (stores) {
          if (stores.isEmpty) {
            return const EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No nearby stores',
              message: 'Try expanding your search radius.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(nearbyStoresProvider);
              await ref.read(nearbyStoresProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _StoreCard(store: stores[i]),
            ),
          );
        },
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final open = store.isOpenNow;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/stores/${store.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  store.name.isNotEmpty ? store.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      store.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (store.distanceKm != null) ...[
                          Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            Formatters.distanceKm(store.distanceKm!),
                            style: context.text.bodySmall,
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.directions_car_outlined,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            Formatters.duration(store.driveTime),
                            style: context.text.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(open ? 'Open' : 'Closed'),
                backgroundColor: open
                    ? colors.tertiaryContainer
                    : colors.errorContainer,
                labelStyle: TextStyle(
                  color: open
                      ? colors.onTertiaryContainer
                      : colors.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
