import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    String? brand,
    String? barcode,
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
