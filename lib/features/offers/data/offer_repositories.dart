import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';

class DemoOfferRepository implements OfferRepository {
  @override
  Future<List<Offer>> activeOffers({String? storeId}) async => DemoSeed.offers
      .where((o) => o.isActive && (storeId == null || o.storeId == storeId))
      .toList();
}

class SupabaseOfferRepository implements OfferRepository {
  SupabaseOfferRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Offer>> activeOffers({String? storeId}) async {
    var query = _client
        .from('offers')
        .select()
        .gt('valid_to', DateTime.now().toIso8601String());
    if (storeId != null) query = query.eq('store_id', storeId);
    final rows = await query.order('valid_to');
    return rows.map(Offer.fromJson).toList();
  }
}

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  if (AppConfig.isDemoMode) return DemoOfferRepository();
  return SupabaseOfferRepository(ref.watch(supabaseClientProvider));
});

final activeOffersProvider = FutureProvider<List<Offer>>(
  (ref) => ref.watch(offerRepositoryProvider).activeOffers(),
);
