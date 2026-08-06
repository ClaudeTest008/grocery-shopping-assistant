import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,

    /// Display name in the catalog's language — per-country demo seeds
    /// (and per-country connected catalogs) localize at the data layer,
    /// so business logic never branches on language.
    required String name,
    String? brand,
    String? barcode,

    /// Additional barcodes for the same product (regional EAN/UPC
    /// variants); [barcode] stays the primary for compatibility.
    List<String>? barcodes,

    /// ISO country codes where this product is sold; null = everywhere
    /// (the shared demo catalog).
    List<String>? countries,
    required String category,

    /// Base unit for unit-price comparison: oz, lb, ct, gal, l, kg...
    @Default('ea') String unit,

    /// Package size in [unit], e.g. 16 (oz).
    @Default(1.0) double unitSize,
    String? imageUrl,

    /// Per-serving nutrition facts, free-form keys (calories, protein_g...).
    Map<String, dynamic>? nutrition,

    /// Dietary tags: vegan, gluten_free, organic...
    @Default(<String>[]) List<String> tags,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
