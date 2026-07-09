import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../stores/data/store_repositories.dart';
import '../../stores/domain/store.dart';

const _austin = LatLng(30.2672, -97.7431);

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Store? _selected;

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(nearbyStoresProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: AsyncValueWidget<List<Store>>(
        value: storesAsync,
        onRetry: () => ref.invalidate(nearbyStoresProvider),
        data: (stores) {
          final initial = stores.isNotEmpty
              ? LatLng(stores.first.lat, stores.first.lng)
              : _austin;
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initial,
                  zoom: 12,
                ),
                myLocationEnabled: false,
                markers: {
                  for (final store in stores)
                    Marker(
                      markerId: MarkerId(store.id),
                      position: LatLng(store.lat, store.lng),
                      infoWindow: InfoWindow(
                        title: store.name,
                        snippet: store.address,
                        onTap: () => context.push('/stores/${store.id}'),
                      ),
                      onTap: () => setState(() => _selected = store),
                    ),
                },
              ),
              if (AppConfig.googleMapsApiKey.isEmpty)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    color: context.colors.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: context.colors.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Map tiles need a Google Maps API key — see '
                              'Deployment docs',
                              style: TextStyle(
                                color: context.colors.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_selected != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selected!.name,
                                  style: context.text.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (_selected!.distanceKm != null)
                                  Text(
                                    Formatters.distanceKm(
                                      _selected!.distanceKm!,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () =>
                                context.push('/stores/${_selected!.id}'),
                            child: const Text('View store'),
                          ),
                        ],
                      ),
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
