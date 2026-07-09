import 'price.dart';
import 'product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> search({String query = '', String? category});

  Future<Product?> byId(String id);

  Future<Product?> byBarcode(String barcode);

  /// Current price at every store carrying the product.
  Future<List<Price>> pricesFor(String productId);

  /// Bulk variant used by the basket optimizer.
  Future<Map<String, List<Price>>> pricesForProducts(List<String> productIds);

  Future<List<PricePoint>> priceHistory(String productId);

  /// Cheaper or dietary-compatible products in the same category.
  Future<List<Product>> alternatives(String productId);

  Future<List<String>> categories();
}
