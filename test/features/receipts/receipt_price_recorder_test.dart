import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_assistant/features/products/data/price_observation_repository.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price.dart';
import 'package:grocery_shopping_assistant/features/products/domain/price_observation.dart';
import 'package:grocery_shopping_assistant/features/products/domain/product.dart';
import 'package:grocery_shopping_assistant/features/products/domain/product_repository.dart';
import 'package:grocery_shopping_assistant/features/receipts/domain/receipt.dart';
import 'package:grocery_shopping_assistant/features/receipts/domain/receipt_price_recorder.dart';

class _FakeProducts implements ProductRepository {
  _FakeProducts(this.catalog);

  final List<Product> catalog;

  @override
  Future<List<Product>> search({String query = '', String? category}) async {
    final q = query.toLowerCase();
    return catalog
        .where((p) => q.isNotEmpty && p.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<Product?> byId(String id) async => null;
  @override
  Future<Product?> byBarcode(String barcode) async => null;
  @override
  Future<List<Price>> pricesFor(String productId) async => [];
  @override
  Future<Map<String, List<Price>>> pricesForProducts(List<String> ids) async =>
      {};
  @override
  Future<List<PricePoint>> priceHistory(String productId) async => [];
  @override
  Future<List<Product>> alternatives(String productId) async => [];
  @override
  Future<List<String>> categories() async => [];
}

class _RecordingObservations implements PriceObservationRepository {
  final recorded = <PriceObservation>[];

  @override
  Future<void> record(PriceObservation observation) async =>
      recorded.add(observation);

  @override
  Future<List<PricePoint>> observationsFor(String productId) async => [];
}

void main() {
  const catalog = [
    Product(id: 'milk', name: 'Whole Milk', category: 'dairy'),
    Product(id: 'eggs', name: 'Large Eggs', category: 'dairy'),
  ];

  Receipt receipt(List<ReceiptItem> items) => Receipt(
    id: 'r1',
    userId: 'u1',
    storeId: 'aldi-1',
    storeName: 'Aldi',
    total: 10,
    purchasedAt: DateTime(2026, 8, 1),
    items: items,
  );

  test('matched lines become receipt-sourced observations', () async {
    final observations = _RecordingObservations();
    final recorded = await ReceiptPriceRecorder.record(
      receipt(const [
        ReceiptItem(id: 'a', receiptId: 'r1', name: 'Whole Milk', price: 3.49),
        ReceiptItem(
          id: 'b',
          receiptId: 'r1',
          name: 'Mystery Snack XL',
          price: 1.99,
        ),
      ]),
      products: _FakeProducts(catalog),
      observations: observations,
    );

    expect(recorded, 1, reason: 'only the confident match records');
    final obs = observations.recorded.single;
    expect(obs.productId, 'milk');
    expect(obs.storeId, 'aldi-1');
    expect(obs.price, 3.49);
    expect(obs.source, 'receipt');
    expect(obs.observedAt, DateTime(2026, 8, 1));
  });

  test('noisy receipt wording still matches the catalog name', () async {
    final observations = _RecordingObservations();
    final recorded = await ReceiptPriceRecorder.record(
      receipt(const [
        ReceiptItem(
          id: 'a',
          receiptId: 'r1',
          name: 'GV LARGE EGGS 12CT',
          price: 2.49,
        ),
      ]),
      products: _FakeProducts(catalog),
      observations: observations,
    );

    expect(recorded, 1);
    expect(observations.recorded.single.productId, 'eggs');
  });

  test('quantity lines record the per-unit price', () async {
    final observations = _RecordingObservations();
    await ReceiptPriceRecorder.record(
      receipt(const [
        ReceiptItem(
          id: 'a',
          receiptId: 'r1',
          name: 'Whole Milk',
          quantity: 2,
          price: 6.98,
        ),
      ]),
      products: _FakeProducts(catalog),
      observations: observations,
    );

    expect(observations.recorded.single.price, closeTo(3.49, 0.001));
  });

  test('zero and negative prices are skipped', () async {
    final observations = _RecordingObservations();
    final recorded = await ReceiptPriceRecorder.record(
      receipt(const [
        ReceiptItem(id: 'a', receiptId: 'r1', name: 'Whole Milk', price: 0),
      ]),
      products: _FakeProducts(catalog),
      observations: observations,
    );

    expect(recorded, 0);
    expect(observations.recorded, isEmpty);
  });
}
