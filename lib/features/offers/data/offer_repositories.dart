import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';

class DemoOfferRepository implements OfferRepository {
  @override
  Future<List<Offer>> activeOffers({String? storeId}) async => DemoSeed.offers
      .where((o) => o.isActive && (storeId == null || o.storeId == storeId))
      .toList();
}

class SupabaseOfferRepository implements OfferRepository {
  SupabaseOfferRepository(this._client, this._store);

  final SupabaseClient _client;
  final LocalStore _store;

  /// Offers expire fast; a short TTL keeps the fallback honest.
  static const _cacheTtl = Duration(hours: 1);

  @override
  Future<List<Offer>> activeOffers({String? storeId}) async {
    final cacheKey = 'offers_active_${storeId ?? 'all'}';
    try {
      var query = _client
          .from('offers')
          .select()
          .gt('valid_to', DateTime.now().toIso8601String());
      if (storeId != null) query = query.eq('store_id', storeId);
      final rows = await query.order('valid_to');
      await _store.putJsonList(cacheKey, rows);
      return rows.map(Offer.fromJson).toList();
    } catch (_) {
      // Offline fallback; re-filter expiry since the clock kept moving.
      final cached = _store.getJsonList(cacheKey, maxAge: _cacheTtl);
      if (cached != null) {
        return cached.map(Offer.fromJson).where((o) => o.isActive).toList();
      }
      rethrow;
    }
  }
}

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  if (AppConfig.isDemoMode) return DemoOfferRepository();
  return SupabaseOfferRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(localStoreProvider),
  );
});

final activeOffersProvider = FutureProvider<List<Offer>>(
  (ref) => ref.watch(offerRepositoryProvider).activeOffers(),
);
