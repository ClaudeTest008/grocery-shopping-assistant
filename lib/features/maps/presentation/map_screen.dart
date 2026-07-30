import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/location_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../offers/data/offer_repositories.dart';
import '../../offers/domain/offer.dart';
import '../../profile/data/preferences_repository.dart';
import '../../stores/data/store_repositories.dart';
import '../../stores/domain/store.dart';
import 'map_providers.dart';

const _austin = LatLng(30.2672, -97.7431);

/// Key-free interactive map (OpenStreetMap / CARTO tiles via
/// flutter_map): animated camera, chain-colored markers with clustering,
/// optimizer route polylines with numbered stops, search + open-now /
/// favorites filters, and a store bottom sheet with offers, favorite
/// toggle and directions.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final _mapController = MapController();
  final _searchController = TextEditingController();

  String _query = '';
  bool _openNowOnly = false;
  bool _favoritesOnly = false;
  double _rotation = 0;
  double _zoom = 12;
  AnimationController? _cameraAnimation;
  bool _didInitialFit = false;

  @override
  void dispose() {
    _cameraAnimation?.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // -- Animated camera ----------------------------------------------------

  void _animateTo(LatLng dest, double zoom) {
    // Respect the OS "reduce motion" setting: jump instead of gliding.
    if (MediaQuery.disableAnimationsOf(context)) {
      _mapController.move(dest, zoom);
      return;
    }
    _cameraAnimation?.dispose();
    final camera = _mapController.camera;
    final latTween = Tween(begin: camera.center.latitude, end: dest.latitude);
    final lngTween = Tween(begin: camera.center.longitude, end: dest.longitude);
    final zoomTween = Tween(begin: camera.zoom, end: zoom);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final anim = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );
    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(anim), lngTween.evaluate(anim)),
        zoomTween.evaluate(anim),
      );
    });
    controller.forward();
    _cameraAnimation = controller;
  }

  void _animateToBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      _animateTo(points.first, 14);
      return;
    }
    final fitted = CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(points),
      padding: const EdgeInsets.fromLTRB(48, 140, 48, 160),
    ).fit(_mapController.camera);
    _animateTo(fitted.center, fitted.zoom);
  }

  // -- Data ---------------------------------------------------------------

  List<Store> _filtered(List<Store> stores, List<String> favorites) {
    final q = _query.toLowerCase();
    return [
      for (final s in stores)
        if ((q.isEmpty ||
                s.name.toLowerCase().contains(q) ||
                s.chain.toLowerCase().contains(q)) &&
            (!_openNowOnly || s.isOpenNow) &&
            (!_favoritesOnly || favorites.contains(s.id)))
          s,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(nearbyStoresProvider);
    final home =
        ref.watch(currentLocationProvider).value ??
        const GeoPoint(30.2672, -97.7431);
    final favorites = ref.watch(preferencesProvider).favoriteStoreIds;
    final trip = ref.watch(tripOverlayProvider);
    final isDark = context.theme.brightness == Brightness.dark;

    return Scaffold(
      body: AsyncValueWidget<List<Store>>(
        value: storesAsync,
        onRetry: () => ref.invalidate(nearbyStoresProvider),
        data: (allStores) {
          final stores = _filtered(allStores, favorites);
          final tripStores =
              trip?.selected.visits.map((v) => v.store).toList() ??
              const <Store>[];
          final homePoint = LatLng(home.lat, home.lng);

          // Frame the map once on first load. Arriving from "View on
          // map" the interesting thing is *this trip*, not every store
          // in the city, so fit the route when one is being shown.
          if (!_didInitialFit && allStores.isNotEmpty) {
            _didInitialFit = true;
            final focus = tripStores.isNotEmpty ? tripStores : allStores;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _animateToBounds([
                  homePoint,
                  for (final s in focus) LatLng(s.lat, s.lng),
                ]);
              }
            });
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: allStores.isEmpty ? _austin : homePoint,
                  initialZoom: 12,
                  maxZoom: 19,
                  onTap: (_, _) => FocusScope.of(context).unfocus(),
                  onPositionChanged: (camera, _) {
                    // Track rotation/zoom for the compass button and
                    // clustering without rebuilding every frame.
                    if ((camera.rotation - _rotation).abs() > 1 ||
                        (camera.zoom - _zoom).abs() > 0.25) {
                      setState(() {
                        _rotation = camera.rotation;
                        _zoom = camera.zoom;
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: isDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    retinaMode: RetinaMode.isHighDensity(context),
                    userAgentPackageName:
                        'com.groceryassistant.grocery_shopping_assistant',
                  ),
                  if (trip != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [
                            homePoint,
                            for (final s in tripStores) LatLng(s.lat, s.lng),
                            homePoint,
                          ],
                          strokeWidth: 5,
                          color: context.colors.primary,
                          borderStrokeWidth: 2,
                          borderColor: context.colors.surface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: homePoint,
                        width: 40,
                        height: 40,
                        child: _HomeMarker(color: context.colors.tertiary),
                      ),
                      ..._buildStoreMarkers(stores, tripStores, favorites),
                    ],
                  ),
                  RichAttributionWidget(
                    alignment: AttributionAlignment.bottomLeft,
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors, CARTO',
                        onTap: () => launchUrl(
                          Uri.parse('https://www.openstreetmap.org/copyright'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _SearchAndFilters(
                controller: _searchController,
                openNowOnly: _openNowOnly,
                favoritesOnly: _favoritesOnly,
                resultCount: stores.length,
                onQuery: (q) => setState(() => _query = q),
                onOpenNow: (v) => setState(() => _openNowOnly = v),
                onFavorites: (v) => setState(() => _favoritesOnly = v),
              ),
              if (trip != null)
                _TripBanner(
                  trip: trip,
                  onSelect: (i) {
                    ref.read(tripOverlayProvider.notifier).state = trip
                        .withIndex(i);
                    final option = trip.result.options[i];
                    _animateToBounds([
                      homePoint,
                      for (final v in option.visits)
                        LatLng(v.store.lat, v.store.lng),
                    ]);
                  },
                  onClose: () =>
                      ref.read(tripOverlayProvider.notifier).state = null,
                ),
              _FloatingControls(
                rotated: _rotation.abs() > 1,
                onLocate: () => _animateTo(homePoint, 14),
                onFitAll: () => _animateToBounds([
                  homePoint,
                  for (final s in stores) LatLng(s.lat, s.lng),
                ]),
                onResetNorth: () {
                  _mapController.rotate(0);
                  setState(() => _rotation = 0);
                },
              ),
              Positioned(
                top: 4,
                left: 4,
                child: SafeArea(
                  child: IconButton.filledTonal(
                    tooltip: 'Back',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -- Markers & clustering -----------------------------------------------

  List<Marker> _buildStoreMarkers(
    List<Store> stores,
    List<Store> tripStores,
    List<String> favorites,
  ) {
    final tripIndex = {
      for (var i = 0; i < tripStores.length; i++) tripStores[i].id: i + 1,
    };
    final clusters = _cluster(stores, _zoom);
    return [
      for (final cluster in clusters)
        if (cluster.length == 1)
          _storeMarker(
            cluster.first,
            tripIndex[cluster.first.id],
            favorites.contains(cluster.first.id),
          )
        else
          Marker(
            point: _centroid(cluster),
            width: 46,
            height: 46,
            child: _ClusterMarker(
              count: cluster.length,
              onTap: () => _animateToBounds([
                for (final s in cluster) LatLng(s.lat, s.lng),
              ]),
            ),
          ),
    ];
  }

  Marker _storeMarker(Store store, int? stopNumber, bool favorite) => Marker(
    point: LatLng(store.lat, store.lng),
    width: 46,
    height: 54,
    alignment: Alignment.topCenter,
    child: _StoreMarker(
      store: store,
      stopNumber: stopNumber,
      favorite: favorite,
      onTap: () {
        _animateTo(
          LatLng(store.lat, store.lng),
          math.max(_mapController.camera.zoom, 14),
        );
        _showStoreSheet(store);
      },
    ),
  );

  /// Screen-space grid clustering: cheap, dependency-free, keeps the map
  /// usable into the thousands of markers. Cell size shrinks as zoom
  /// grows; beyond zoom 14 everything is its own marker.
  List<List<Store>> _cluster(List<Store> stores, double zoom) {
    if (zoom >= 14 || stores.length <= 12) {
      return [
        for (final s in stores) [s],
      ];
    }
    final cellDeg = 0.7 / math.pow(2, zoom - 8);
    final buckets = <String, List<Store>>{};
    for (final s in stores) {
      final key = '${(s.lat / cellDeg).floor()}:${(s.lng / cellDeg).floor()}';
      buckets.putIfAbsent(key, () => []).add(s);
    }
    return buckets.values.toList();
  }

  LatLng _centroid(List<Store> stores) => LatLng(
    stores.map((s) => s.lat).reduce((a, b) => a + b) / stores.length,
    stores.map((s) => s.lng).reduce((a, b) => a + b) / stores.length,
  );

  // -- Store sheet ----------------------------------------------------------

  void _showStoreSheet(Store store) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _StoreSheet(store: store),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

const _chainColors = <String, Color>{
  'aldi': Color(0xFF00458F),
  'walmart': Color(0xFF0071CE),
  'kroger': Color(0xFF16375C),
  'target': Color(0xFFCC0000),
  'heb': Color(0xFFDC291E),
  'traderjoes': Color(0xFFB22222),
};

class _StoreMarker extends StatelessWidget {
  const _StoreMarker({
    required this.store,
    required this.onTap,
    this.stopNumber,
    this.favorite = false,
  });

  final Store store;
  final VoidCallback onTap;
  final int? stopNumber;
  final bool favorite;

  @override
  Widget build(BuildContext context) {
    final color = _chainColors[store.chain] ?? context.colors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label:
            '${store.name}, ${store.isOpenNow ? 'open' : 'closed'}'
            '${stopNumber != null ? ', stop $stopNumber' : ''}',
        button: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stopNumber != null
                          ? context.colors.primary
                          : Colors.white,
                      width: stopNumber != null ? 3 : 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: stopNumber != null
                      ? Center(
                          child: Text(
                            '$stopNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.shopping_basket_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                if (favorite)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            // Pin tail.
            CustomPaint(
              size: const Size(12, 8),
              painter: _PinTailPainter(color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => old.color != color;
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: '$count stores, tap to zoom in',
        button: true,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMarker extends StatelessWidget {
  const _HomeMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your location',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.openNowOnly,
    required this.favoritesOnly,
    required this.resultCount,
    required this.onQuery,
    required this.onOpenNow,
    required this.onFavorites,
  });

  final TextEditingController controller;
  final bool openNowOnly;
  final bool favoritesOnly;
  final int resultCount;
  final ValueChanged<String> onQuery;
  final ValueChanged<bool> onOpenNow;
  final ValueChanged<bool> onFavorites;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(60, 8, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SearchBar(
              controller: controller,
              hintText: 'Search stores',
              leading: const Icon(Icons.search_rounded),
              onChanged: onQuery,
              elevation: const WidgetStatePropertyAll(3),
              constraints: const BoxConstraints(minHeight: 48, maxWidth: 560),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Open now'),
                  selected: openNowOnly,
                  onSelected: onOpenNow,
                  avatar: openNowOnly
                      ? null
                      : const Icon(Icons.schedule_rounded, size: 16),
                ),
                FilterChip(
                  label: const Text('Favorites'),
                  selected: favoritesOnly,
                  onSelected: onFavorites,
                  avatar: favoritesOnly
                      ? null
                      : const Icon(Icons.star_outline_rounded, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripBanner extends StatelessWidget {
  const _TripBanner({
    required this.trip,
    required this.onSelect,
    required this.onClose,
  });

  final TripOverlay trip;
  final ValueChanged<int> onSelect;
  final VoidCallback onClose;

  /// Hands the whole optimized run to the phone's navigation app, in the
  /// order the optimizer worked out. Without this the app's most
  /// expensive computation ends as a drawing.
  Future<void> _startTrip(BuildContext context) async {
    final stops = trip.selected.visits;
    if (stops.isEmpty) return;

    final destination = stops.last;
    final waypoints = stops
        .take(stops.length - 1)
        .map((v) => '${v.store.lat},${v.store.lng}')
        .join('|');

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${destination.store.lat},${destination.store.lng}'
      '${waypoints.isEmpty ? '' : '&waypoints=$waypoints'}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        context.showSnack('Could not open navigation', error: true);
      }
    } catch (_) {
      if (context.mounted) {
        context.showSnack('Could not open navigation', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final option = trip.selected;
    final stores = option.visits.map((v) => v.store.name).join(' → ');
    return Positioned(
      left: 12,
      right: 12,
      bottom: 24,
      child: SafeArea(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Home → $stores → Home',
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hide trip',
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(
                  '${Formatters.currency(option.totalCost)} all-in · '
                  '${Formatters.distanceKm(option.travelKm)} · '
                  '${Formatters.duration(option.travelTime)}',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                if (option.savingsVsBaseline > 0.01)
                  Text(
                    'Saves ${Formatters.currency(option.savingsVsBaseline)} '
                    'vs your nearest store',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (var i = 0; i < trip.result.options.length; i++)
                            ChoiceChip(
                              label: Text(
                                '${String.fromCharCode(65 + i)} · '
                                '${Formatters.currency(trip.result.options[i].totalCost)}',
                              ),
                              selected: i == trip.selectedIndex,
                              onSelected: (_) => onSelect(i),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => _startTrip(context),
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: const Text('Start trip'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingControls extends StatelessWidget {
  const _FloatingControls({
    required this.rotated,
    required this.onLocate,
    required this.onFitAll,
    required this.onResetNorth,
  });

  final bool rotated;
  final VoidCallback onLocate;
  final VoidCallback onFitAll;
  final VoidCallback onResetNorth;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      top: 120,
      child: SafeArea(
        child: Column(
          children: [
            if (rotated) ...[
              FloatingActionButton.small(
                heroTag: 'map-north',
                tooltip: 'Reset north',
                onPressed: onResetNorth,
                child: const Icon(Icons.explore_rounded),
              ),
              const SizedBox(height: 8),
            ],
            FloatingActionButton.small(
              heroTag: 'map-locate',
              tooltip: 'My location',
              onPressed: onLocate,
              child: const Icon(Icons.my_location_rounded),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'map-fit',
              tooltip: 'Show all stores',
              onPressed: onFitAll,
              child: const Icon(Icons.fit_screen_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreSheet extends ConsumerWidget {
  const _StoreSheet({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final favorite = prefs.favoriteStoreIds.contains(store.id);
    final offers = ref.watch(_storeOffersProvider(store.id));
    final todayHours =
        store.openingHours?['${DateTime.now().weekday}'] ?? 'unknown';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    _chainColors[store.chain] ?? context.colors.primary,
                child: const Icon(
                  Icons.shopping_basket_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: context.text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      store.address,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: favorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: () {
                  final ids = [...prefs.favoriteStoreIds];
                  favorite ? ids.remove(store.id) : ids.add(store.id);
                  ref
                      .read(preferencesProvider.notifier)
                      .update(prefs.copyWith(favoriteStoreIds: ids));
                },
                icon: Icon(
                  favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: favorite ? Colors.amber.shade700 : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(
                  store.isOpenNow
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 16,
                  color: store.isOpenNow
                      ? context.colors.primary
                      : context.colors.error,
                ),
                label: Text(
                  store.isOpenNow
                      ? 'Open · today $todayHours'
                      : 'Closed · today $todayHours',
                ),
              ),
              if (store.distanceKm != null)
                Chip(
                  avatar: const Icon(Icons.directions_car_outlined, size: 16),
                  label: Text(
                    '${Formatters.distanceKm(store.distanceKm!)} · '
                    '${Formatters.duration(store.driveTime)}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          offers.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (items) => items.isEmpty
                ? Text(
                    'No active offers at this store.',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${items.length} active offer${items.length == 1 ? '' : 's'}',
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (final offer in items.take(3))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer_rounded,
                                size: 14,
                                color: context.colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  offer.title,
                                  style: context.text.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openDirections(context),
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Directions'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/stores/${store.id}');
                  },
                  icon: const Icon(Icons.storefront_rounded),
                  label: const Text('View store'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${store.lat},${store.lng}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        context.showSnack('Could not open directions', error: true);
      }
    } catch (_) {
      if (context.mounted) {
        context.showSnack('Could not open directions', error: true);
      }
    }
  }
}

final _storeOffersProvider = FutureProvider.family<List<Offer>, String>(
  (ref, storeId) =>
      ref.watch(offerRepositoryProvider).activeOffers(storeId: storeId),
);
