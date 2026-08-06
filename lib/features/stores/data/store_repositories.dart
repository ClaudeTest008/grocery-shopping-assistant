import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/observability/telemetry.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/store.dart';
import '../domain/store_repository.dart';

List<Store> _sortByDistance(
  Iterable<Store> stores,
  GeoPoint location,
  double radiusKm,
) {
  final withDistance = [
    for (final s in stores)
      s.copyWith(distanceKm: location.distanceKmTo(GeoPoint(s.lat, s.lng))),
  ]..removeWhere((s) => s.distanceKm! > radiusKm);
  withDistance.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
  return withDistance;
}

class DemoStoreRepository implements StoreRepository {
  @override
  Future<List<Store>> nearby(GeoPoint location, {double radiusKm = 25}) async =>
      _sortByDistance(DemoSeed.stores, location, radiusKm);

  @override
  Future<Store?> byId(String id) async =>
      DemoSeed.stores.where((s) => s.id == id).firstOrNull;
}

class SupabaseStoreRepository implements StoreRepository {
  SupabaseStoreRepository(this._client, this._store);

  final SupabaseClient _client;
  final LocalStore _store;

  /// Stores move rarely; a day-old list beats a blank map when offline.
  static const _cacheTtl = Duration(hours: 24);
  static const _cacheKey = 'stores_nearby';

  @override
  Future<List<Store>> nearby(GeoPoint location, {double radiusKm = 25}) async {
    try {
      // Bounding-box prefilter in SQL, precise sort client-side.
      // Country narrows the query so countries load independently —
      // a Lisbon user never downloads the Berlin dataset.
      final latDelta = radiusKm / 111.0;
      final rows = await _client
          .from('stores')
          .select()
          .eq('country', DemoSeed.country.code)
          .gte('lat', location.lat - latDelta)
          .lte('lat', location.lat + latDelta);
      await _store.putJsonList(_cacheKey, rows);
      return _sortByDistance(rows.map(Store.fromJson), location, radiusKm);
    } catch (error, stack) {
      // Auth problems must surface — serving cache would hide an
      // expired session until every screen quietly went stale.
      if (error is AuthException) rethrow;
      // Offline fallback: last fetched stores, re-sorted for the
      // current location (which may have moved since the fetch).
      // Recorded so a server-side failure doesn't hide behind it.
      Telemetry.recordError(error, stack);
      final cached = _store.getJsonList(_cacheKey, maxAge: _cacheTtl);
      if (cached != null) {
        return _sortByDistance(cached.map(Store.fromJson), location, radiusKm);
      }
      rethrow;
    }
  }

  @override
  Future<Store?> byId(String id) async {
    final row = await _client
        .from('stores')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Store.fromJson(row);
  }
}

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  if (AppConfig.isDemoMode) return DemoStoreRepository();
  return SupabaseStoreRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(localStoreProvider),
  );
});

/// Nearby stores for the current location.
final nearbyStoresProvider = FutureProvider<List<Store>>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  return ref.watch(storeRepositoryProvider).nearby(location);
});
