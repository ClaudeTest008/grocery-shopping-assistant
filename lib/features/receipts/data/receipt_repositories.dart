import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_collection.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/receipt.dart';
import '../domain/receipt_repository.dart';

class DemoReceiptRepository implements ReceiptRepository {
  DemoReceiptRepository(LocalStore store)
    : _receipts = DemoCollection(
        store,
        'demo_receipts',
        fromJson: Receipt.fromJson,
        toJson: (r) => r.toJson(),
        seed: _seed,
      );

  final DemoCollection<Receipt> _receipts;

  /// Three months of receipts so the budget charts and predictions have
  /// something real to chew on.
  static List<Receipt> _seed() {
    const uuid = Uuid();
    final now = DateTime.now();
    final out = <Receipt>[];
    const storeRotation = ['aldi-1', 'heb-1', 'walmart-1', 'kroger-1'];
    const storeNames = ['Aldi', 'H-E-B', 'Walmart', 'Kroger'];
    const categories = ['produce', 'dairy', 'meat', 'pantry', 'frozen'];
    for (var week = 12; week >= 1; week--) {
      final receiptId = uuid.v4();
      final storeIdx = week % storeRotation.length;
      // Deterministic weekly variation: $45-$75.
      final total = 45 + (week * 7919) % 31.0;
      final itemCount = 4;
      final items = <ReceiptItem>[
        for (var i = 0; i < itemCount; i++)
          ReceiptItem(
            id: uuid.v4(),
            receiptId: receiptId,
            name: 'Item ${i + 1}',
            price: double.parse((total / itemCount).toStringAsFixed(2)),
            category: categories[(week + i) % categories.length],
          ),
      ];
      out.add(
        Receipt(
          id: receiptId,
          userId: DemoSeed.demoUserId,
          storeId: storeRotation[storeIdx],
          storeName: storeNames[storeIdx],
          total: double.parse(total.toStringAsFixed(2)),
          purchasedAt: now.subtract(Duration(days: week * 7)),
          items: items,
        ),
      );
    }
    return out;
  }

  @override
  Future<List<Receipt>> receipts() async =>
      _receipts.load()..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));

  @override
  Future<void> add(Receipt receipt) =>
      _receipts.upsert(receipt, (r) => r.id == receipt.id);

  @override
  Future<void> remove(String id) => _receipts.removeWhere((r) => r.id == id);
}

class SupabaseReceiptRepository implements ReceiptRepository {
  SupabaseReceiptRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Receipt>> receipts() async {
    final rows = await _client
        .from('receipts')
        .select('*, receipt_items(*)')
        .eq('user_id', _userId)
        .order('purchased_at', ascending: false);
    return rows.map((row) {
      final items = (row.remove('receipt_items') as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ReceiptItem.fromJson)
          .toList();
      return Receipt.fromJson(row).copyWith(items: items);
    }).toList();
  }

  @override
  Future<void> add(Receipt receipt) async {
    final row = await _client
        .from('receipts')
        .insert({
          'user_id': _userId,
          'store_id': receipt.storeId,
          'store_name': receipt.storeName,
          'total': receipt.total,
          'currency': receipt.currency,
          'purchased_at': receipt.purchasedAt.toIso8601String(),
          'image_url': receipt.imageUrl,
        })
        .select()
        .single();
    if (receipt.items.isNotEmpty) {
      await _client.from('receipt_items').insert([
        for (final i in receipt.items)
          {
            'receipt_id': row['id'],
            'name': i.name,
            'quantity': i.quantity,
            'price': i.price,
            'category': i.category,
          },
      ]);
    }
  }

  @override
  Future<void> remove(String id) =>
      _client.from('receipts').delete().eq('id', id);
}

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  if (AppConfig.isDemoMode) {
    return DemoReceiptRepository(ref.watch(localStoreProvider));
  }
  return SupabaseReceiptRepository(ref.watch(supabaseClientProvider));
});
