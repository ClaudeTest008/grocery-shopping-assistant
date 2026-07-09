import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/coupon.dart';
import '../domain/coupon_repository.dart';

class DemoCouponRepository implements CouponRepository {
  DemoCouponRepository(this._store);

  final LocalStore _store;

  Set<String> get _clipped =>
      (_store.prefs.get('clipped_coupons') as List?)?.cast<String>().toSet() ??
      {};

  @override
  Future<List<Coupon>> available() async {
    final clipped = _clipped;
    return DemoSeed.coupons
        .where((c) => !c.isExpired)
        .map((c) => c.copyWith(clipped: clipped.contains(c.id)))
        .toList();
  }

  @override
  Future<void> setClipped(String couponId, bool clipped) async {
    final set = _clipped;
    clipped ? set.add(couponId) : set.remove(couponId);
    await _store.prefs.put('clipped_coupons', set.toList());
  }
}

class SupabaseCouponRepository implements CouponRepository {
  SupabaseCouponRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Coupon>> available() async {
    final rows = await _client
        .from('coupons')
        .select('*, user_coupons(user_id)')
        .gt('expires_at', DateTime.now().toIso8601String());
    return rows.map((row) {
      final clips = ((row['user_coupons'] as List?) ?? const [])
          .whereType<Map>();
      row.remove('user_coupons');
      final clipped = clips.any((c) => c['user_id'] == _userId);
      return Coupon.fromJson(row).copyWith(clipped: clipped);
    }).toList();
  }

  @override
  Future<void> setClipped(String couponId, bool clipped) async {
    if (clipped) {
      await _client.from('user_coupons').upsert({
        'user_id': _userId,
        'coupon_id': couponId,
      });
    } else {
      await _client
          .from('user_coupons')
          .delete()
          .eq('user_id', _userId)
          .eq('coupon_id', couponId);
    }
  }
}

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  if (AppConfig.isDemoMode) {
    return DemoCouponRepository(ref.watch(localStoreProvider));
  }
  return SupabaseCouponRepository(ref.watch(supabaseClientProvider));
});

final couponsProvider = FutureProvider<List<Coupon>>(
  (ref) => ref.watch(couponRepositoryProvider).available(),
);
