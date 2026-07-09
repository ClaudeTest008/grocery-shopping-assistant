import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/price.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';

class DemoProductRepository implements ProductRepository {
  @override
  Future<List<Product>> search({String query = '', String? category}) async {
    final q = query.toLowerCase();
    return DemoSeed.products
        .where(
          (p) =>
              (category == null || p.category == category) &&
              (q.isEmpty ||
                  p.name.toLowerCase().contains(q) ||
                  (p.brand?.toLowerCase().contains(q) ?? false)),
        )
        .toList();
  }

  @override
  Future<Product?> byId(String id) async =>
      DemoSeed.products.where((p) => p.id == id).firstOrNull;

  @override
  Future<Product?> byBarcode(String barcode) async =>
      DemoSeed.products.where((p) => p.barcode == barcode).firstOrNull;

  @override
  Future<List<Price>> pricesFor(String productId) async =>
      DemoSeed.prices.where((p) => p.productId == productId).toList();

  @override
  Future<Map<String, List<Price>>> pricesForProducts(
    List<String> productIds,
  ) async {
    final ids = productIds.toSet();
    final result = <String, List<Price>>{};
    for (final price in DemoSeed.prices) {
      if (ids.contains(price.productId)) {
        result.putIfAbsent(price.productId, () => []).add(price);
      }
    }
    return result;
  }

  @override
  Future<List<PricePoint>> priceHistory(String productId) async =>
      DemoSeed.priceHistory(productId);

  @override
  Future<List<Product>> alternatives(String productId) async {
    final product = await byId(productId);
    if (product == null) return [];
    return DemoSeed.products
        .where((p) => p.category == product.category && p.id != productId)
        .toList();
  }

  @override
  Future<List<String>> categories() async =>
      DemoSeed.products.map((p) => p.category).toSet().toList()..sort();
}

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository(this._client, this._store);

  final SupabaseClient _client;
  final LocalStore _store;

  static const _cacheTtl = Duration(hours: 6);

  @override
  Future<List<Product>> search({String query = '', String? category}) async {
    try {
      var builder = _client.from('products').select();
      if (category != null) builder = builder.eq('category', category);
      if (query.isNotEmpty) builder = builder.ilike('name', '%$query%');
      final rows = await builder.limit(50);
      return rows.map(Product.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message, e);
    }
  }

  @override
  Future<Product?> byId(String id) async {
    final row = await _client
        .from('products')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Product.fromJson(row);
  }

  @override
  Future<Product?> byBarcode(String barcode) async {
    final row = await _client
        .from('products')
        .select()
        .eq('barcode', barcode)
        .maybeSingle();
    return row == null ? null : Product.fromJson(row);
  }

  @override
  Future<List<Price>> pricesFor(String productId) async {
    final cacheKey = 'prices_$productId';
    try {
      final rows = await _client
          .from('prices')
          .select()
          .eq('product_id', productId);
      final prices = rows.map(Price.fromJson).toList();
      await _store.putJsonList(cacheKey, rows);
      return prices;
    } catch (_) {
      // Offline fallback: serve last known prices.
      final cached = _store.getJsonList(cacheKey, maxAge: _cacheTtl);
      if (cached != null) return cached.map(Price.fromJson).toList();
      rethrow;
    }
  }

  @override
  Future<Map<String, List<Price>>> pricesForProducts(
    List<String> productIds,
  ) async {
    final rows = await _client
        .from('prices')
        .select()
        .inFilter('product_id', productIds);
    final result = <String, List<Price>>{};
    for (final row in rows) {
      final price = Price.fromJson(row);
      result.putIfAbsent(price.productId, () => []).add(price);
    }
    return result;
  }

  @override
  Future<List<PricePoint>> priceHistory(String productId) async {
    final rows = await _client
        .from('price_history')
        .select('recorded_at, price, store_id')
        .eq('product_id', productId)
        .order('recorded_at', ascending: true);
    return rows.map(PricePoint.fromJson).toList();
  }

  @override
  Future<List<Product>> alternatives(String productId) async {
    final product = await byId(productId);
    if (product == null) return [];
    final rows = await _client
        .from('products')
        .select()
        .eq('category', product.category)
        .neq('id', productId)
        .limit(10);
    return rows.map(Product.fromJson).toList();
  }

  @override
  Future<List<String>> categories() async {
    final rows = await _client.from('products').select('category');
    return rows.map((r) => r['category'] as String).toSet().toList()..sort();
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (AppConfig.isDemoMode) return DemoProductRepository();
  return SupabaseProductRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(localStoreProvider),
  );
});
