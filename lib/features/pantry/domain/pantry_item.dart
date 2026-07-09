import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_item.freezed.dart';
part 'pantry_item.g.dart';

@freezed
abstract class PantryItem with _$PantryItem {
  const PantryItem._();

  const factory PantryItem({
    required String id,
    required String userId,
    String? productId,
    required String name,
    @Default(1.0) double quantity,
    @Default('ea') String unit,
    DateTime? expiresAt,

    /// fridge, freezer, pantry...
    @Default('pantry') String location,
    DateTime? addedAt,
  }) = _PantryItem;

  factory PantryItem.fromJson(Map<String, dynamic> json) =>
      _$PantryItemFromJson(json);

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get expiresSoon =>
      expiresAt != null &&
      !isExpired &&
      expiresAt!.difference(DateTime.now()).inDays <= 3;
}
