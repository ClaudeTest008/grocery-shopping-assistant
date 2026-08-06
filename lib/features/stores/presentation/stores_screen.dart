import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/store_repositories.dart';
import '../domain/store.dart';

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
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
            // Radius is fixed at 25 km; there is no control to change it.
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No nearby stores',
              message: 'No stores within 25 km of your location.',
              actionLabel: 'View map',
              onAction: () => context.push('/map'),
            );
          }
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty
              ? stores
              : stores
                    .where(
                      (s) =>
                          s.name.toLowerCase().contains(q) ||
                          s.chain.toLowerCase().contains(q),
                    )
                    .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  hintText: 'Search stores',
                  leading: const Icon(Icons.search_rounded),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No matching stores',
                        message: 'Try a different store or chain name.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(nearbyStoresProvider);
                          await ref.read(nearbyStoresProvider.future);
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              _StoreCard(store: filtered[i]),
                        ),
                      ),
              ),
            ],
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
