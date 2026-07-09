import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

@freezed
abstract class Receipt with _$Receipt {
  const factory Receipt({
    required String id,
    required String userId,
    String? storeId,
    String? storeName,
    required double total,
    @Default('USD') String currency,
    required DateTime purchasedAt,
    String? imageUrl,
    @Default(<ReceiptItem>[]) List<ReceiptItem> items,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);
}

@freezed
abstract class ReceiptItem with _$ReceiptItem {
  const factory ReceiptItem({
    required String id,
    required String receiptId,
    required String name,
    @Default(1.0) double quantity,
    required double price,
    String? category,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);
}
