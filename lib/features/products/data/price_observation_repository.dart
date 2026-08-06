import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_collection.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/price.dart';
import '../domain/price_observation.dart';

/// Stores the prices a user personally observed (receipts, manual
/// reports) and serves them back as history points. Connected builds
/// write to `price_submissions`, where RLS keeps rows owner-only until
/// an operator promotes them into the shared catalog history.
abstract class PriceObservationRepository {
  Future<void> record(PriceObservation observation);

  /// This user's own observations for one product, oldest first.
  Future<List<PricePoint>> observationsFor(String productId);
}

class DemoPriceObservationRepository implements PriceObservationRepository {
  DemoPriceObservationRepository(LocalStore store)
    : _observations = DemoCollection(
        store,
        'demo_price_observations',
        fromJson: PriceObservation.fromJson,
        toJson: (o) => o.toJson(),
      );

  final DemoCollection<PriceObservation> _observations;

  @override
  Future<void> record(PriceObservation observation) =>
      _observations.upsert(observation, (o) => o.id == observation.id);

  @override
  Future<List<PricePoint>> observationsFor(String productId) async =>
      (_observations.load().where((o) => o.productId == productId).toList()
            ..sort((a, b) => a.observedAt.compareTo(b.observedAt)))
          .map(
            (o) => PricePoint(
              recordedAt: o.observedAt,
              price: o.price,
              storeId: o.storeId,
              source: o.source,
            ),
          )
          .toList();
}

class SupabasePriceObservationRepository implements PriceObservationRepository {
  SupabasePriceObservationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> record(PriceObservation observation) async {
    try {
      await _client.from('price_submissions').insert({
        'user_id': _client.requireUserId,
        'product_id': observation.productId,
        'store_id': observation.storeId,
        'price': observation.price,
        'source': observation.source,
        'submitted_at': observation.observedAt.toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message, e);
    }
  }

  @override
  Future<List<PricePoint>> observationsFor(String productId) async {
    final rows = await _client
        .from('price_submissions')
        .select('store_id, price, source, submitted_at')
        .eq('product_id', productId)
        .eq('user_id', _client.requireUserId)
        .order('submitted_at', ascending: true);
    return rows
        .map(
          (r) => PricePoint(
            recordedAt: DateTime.parse(r['submitted_at'] as String),
            price: (r['price'] as num).toDouble(),
            storeId: r['store_id'] as String?,
            source: r['source'] as String?,
          ),
        )
        .toList();
  }
}

final priceObservationRepositoryProvider = Provider<PriceObservationRepository>(
  (ref) {
    if (AppConfig.isDemoMode) {
      return DemoPriceObservationRepository(ref.watch(localStoreProvider));
    }
    return SupabasePriceObservationRepository(
      ref.watch(supabaseClientProvider),
    );
  },
);
