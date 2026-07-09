import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/store.dart';
import '../domain/store_repository.dart';

List<Store> _sortByDistance(
    Iterable<Store> stores, GeoPoint location, double radiusKm) {
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
  SupabaseStoreRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Store>> nearby(GeoPoint location,
      {double radiusKm = 25}) async {
    // Bounding-box prefilter in SQL, precise sort client-side.
    final latDelta = radiusKm / 111.0;
    final rows = await _client
        .from('stores')
        .select()
        .gte('lat', location.lat - latDelta)
        .lte('lat', location.lat + latDelta);
    return _sortByDistance(rows.map(Store.fromJson), location, radiusKm);
  }

  @override
  Future<Store?> byId(String id) async {
    final row =
        await _client.from('stores').select().eq('id', id).maybeSingle();
    return row == null ? null : Store.fromJson(row);
  }
}

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  if (AppConfig.isDemoMode) return DemoStoreRepository();
  return SupabaseStoreRepository(ref.watch(supabaseClientProvider));
});

/// Nearby stores for the current location.
final nearbyStoresProvider = FutureProvider<List<Store>>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  return ref.watch(storeRepositoryProvider).nearby(location);
});
