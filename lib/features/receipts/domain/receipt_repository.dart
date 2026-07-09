import 'receipt.dart';

abstract interface class ReceiptRepository {
  Future<List<Receipt>> receipts();

  Future<void> add(Receipt receipt);

  Future<void> remove(String id);
}
