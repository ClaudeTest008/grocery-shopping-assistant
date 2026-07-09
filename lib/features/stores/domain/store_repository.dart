import '../../../core/services/location_service.dart';
import 'store.dart';

abstract interface class StoreRepository {
  /// Stores within [radiusKm] of [location], sorted by distance, with
  /// [Store.distanceKm] populated.
  Future<List<Store>> nearby(GeoPoint location, {double radiusKm = 25});

  Future<Store?> byId(String id);
}
