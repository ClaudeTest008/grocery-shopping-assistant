import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

/// A product identified through Open Food Facts — the world's largest
/// open barcode database (openfoodfacts.org, ODbL-licensed). Metadata
/// only: OFF knows what a barcode is, not what your store charges for it.
class ExternalProduct {
  const ExternalProduct({required this.name, this.brand, this.imageUrl});

  final String name;
  final String? brand;
  final String? imageUrl;

  /// Parses the OFF v2 response shape `{status, product: {...}}`.
  /// Returns null when the barcode is unknown or the payload is missing
  /// a usable name — callers treat that the same as "not found".
  static ExternalProduct? fromOffJson(Map<String, dynamic> json) {
    if (json['status'] != 1) return null;
    final product = json['product'];
    if (product is! Map<String, dynamic>) return null;
    final name = (product['product_name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;
    return ExternalProduct(
      name: name,
      brand: switch ((product['brands'] as String?)?.trim()) {
        null || '' => null,
        // OFF concatenates brands with commas; the first is the primary.
        final b => b.split(',').first.trim(),
      },
      imageUrl: product['image_front_small_url'] as String?,
    );
  }

  String get label => brand == null ? name : '$name — $brand';
}

/// Barcode fallback for products outside the local catalog. This is a
/// real, live integration (no key required); it turns the former
/// "No product found" dead end into an identified item.
class OpenFoodFactsClient {
  OpenFoodFactsClient(this._dio);

  final Dio _dio;

  static const _base = 'https://world.openfoodfacts.org/api/v2/product';

  /// Looks up [barcode], returning null on unknown codes AND on any
  /// network error — callers show the same graceful fallback either way.
  Future<ExternalProduct?> byBarcode(String barcode) async {
    final code = barcode.trim();
    // EAN-8..EAN-13/UPC lengths; anything else can't be a retail barcode.
    if (!RegExp(r'^\d{8,14}$').hasMatch(code)) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_base/$code',
        queryParameters: {
          'fields': 'product_name,brands,image_front_small_url',
        },
        options: Options(
          // OFF asks API users to identify themselves.
          headers: {
            'User-Agent':
                'GroceryShoppingAssistant/1.0 (support@grocery-assistant.app)',
          },
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final data = res.data;
      return data == null ? null : ExternalProduct.fromOffJson(data);
    } catch (_) {
      return null;
    }
  }
}

final openFoodFactsClientProvider = Provider<OpenFoodFactsClient>(
  (ref) => OpenFoodFactsClient(ref.watch(dioProvider)),
);
