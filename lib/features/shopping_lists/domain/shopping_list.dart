import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_list.freezed.dart';
part 'shopping_list.g.dart';

@freezed
abstract class ShoppingList with _$ShoppingList {
  const ShoppingList._();

  const factory ShoppingList({
    required String id,
    required String userId,
    required String name,

    /// Optional spending cap for this trip.
    double? budget,
    @Default(<ShoppingItem>[]) List<ShoppingItem> items,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ShoppingList;

  factory ShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListFromJson(json);

  int get checkedCount => items.where((i) => i.checked).length;

  double get progress => items.isEmpty ? 0 : checkedCount / items.length;
}

@freezed
abstract class ShoppingItem with _$ShoppingItem {
  const factory ShoppingItem({
    required String id,
    required String listId,

    /// Linked catalog product when known; free-text items have null.
    String? productId,
    required String name,
    @Default(1.0) double quantity,
    @Default('ea') String unit,
    @Default(false) bool checked,
    String? notes,

    /// Estimated price used before optimization resolves real prices.
    double? estimatedPrice,
  }) = _ShoppingItem;

  factory ShoppingItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemFromJson(json);
}
