import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../core/demo/demo_collection.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/local_store.dart';
import '../domain/shopping_list.dart';
import '../domain/shopping_list_repository.dart';

const _uuid = Uuid();

class DemoShoppingListRepository implements ShoppingListRepository {
  DemoShoppingListRepository(LocalStore store)
    : _lists = DemoCollection(
        store,
        'demo_shopping_lists',
        fromJson: ShoppingList.fromJson,
        toJson: (l) => l.toJson(),
        seed: _seedLists,
      );

  final DemoCollection<ShoppingList> _lists;

  static List<ShoppingList> _seedLists() {
    final listId = _uuid.v4();
    ShoppingItem item(
      String productId,
      String name,
      double qty, [
      String unit = 'ea',
    ]) => ShoppingItem(
      id: _uuid.v4(),
      listId: listId,
      productId: productId,
      name: name,
      quantity: qty,
      unit: unit,
    );
    return [
      ShoppingList(
        id: listId,
        userId: DemoSeed.demoUserId,
        name: 'Weekly groceries',
        budget: 60,
        createdAt: DateTime.now(),
        items: [
          item('milk', 'Whole Milk', 1, 'gal'),
          item('eggs', 'Large Eggs, Dozen', 1, 'ct'),
          item('bananas', 'Bananas', 2, 'lb'),
          item('chicken', 'Chicken Breast', 2, 'lb'),
          item('rice', 'Long Grain Rice', 1, 'bag'),
          item('beans', 'Black Beans', 3, 'can'),
          item('bread', 'Whole Wheat Bread', 1, 'loaf'),
          item('pasta', 'Spaghetti', 2, 'box'),
          item('cheddar', 'Shredded Cheddar', 1, 'bag'),
          item('coffee', 'Ground Coffee', 1, 'bag'),
        ],
      ),
    ];
  }

  @override
  Future<List<ShoppingList>> lists() async =>
      _lists.load()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<ShoppingList?> byId(String id) async =>
      _lists.load().where((l) => l.id == id).firstOrNull;

  @override
  Future<ShoppingList> create(String name, {double? budget}) async {
    final list = ShoppingList(
      id: _uuid.v4(),
      userId: DemoSeed.demoUserId,
      name: name,
      budget: budget,
      createdAt: DateTime.now(),
    );
    await _lists.upsert(list, (l) => l.id == list.id);
    return list;
  }

  @override
  Future<void> rename(String id, String name, {double? budget}) async {
    final list = await byId(id);
    if (list == null) return;
    await _lists.upsert(
      list.copyWith(name: name, budget: budget, updatedAt: DateTime.now()),
      (l) => l.id == id,
    );
  }

  @override
  Future<void> delete(String id) => _lists.removeWhere((l) => l.id == id);

  @override
  Future<ShoppingList> duplicate(String id) async {
    final source = await byId(id);
    if (source == null) throw StateError('List $id not found');
    final newId = _uuid.v4();
    final copy = source.copyWith(
      id: newId,
      name: '${source.name} (copy)',
      createdAt: DateTime.now(),
      updatedAt: null,
      items: [
        for (final i in source.items)
          i.copyWith(id: _uuid.v4(), listId: newId, checked: false),
      ],
    );
    await _lists.upsert(copy, (l) => l.id == newId);
    return copy;
  }

  @override
  Future<void> addItem(String listId, ShoppingItem item) async {
    final list = await byId(listId);
    if (list == null) return;
    await _lists.upsert(
      list.copyWith(items: [...list.items, item]),
      (l) => l.id == listId,
    );
  }

  @override
  Future<void> updateItem(ShoppingItem item) async {
    final list = await byId(item.listId);
    if (list == null) return;
    await _lists.upsert(
      list.copyWith(
        items: [for (final i in list.items) i.id == item.id ? item : i],
      ),
      (l) => l.id == item.listId,
    );
  }

  @override
  Future<void> removeItem(String listId, String itemId) async {
    final list = await byId(listId);
    if (list == null) return;
    await _lists.upsert(
      list.copyWith(items: list.items.where((i) => i.id != itemId).toList()),
      (l) => l.id == listId,
    );
  }
}

class SupabaseShoppingListRepository implements ShoppingListRepository {
  SupabaseShoppingListRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  static const _select = '*, shopping_items(*)';

  ShoppingList _fromRow(Map<String, dynamic> row) {
    final items = (row.remove('shopping_items') as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ShoppingItem.fromJson)
        .toList();
    return ShoppingList.fromJson(row).copyWith(items: items);
  }

  @override
  Future<List<ShoppingList>> lists() async {
    final rows = await _client
        .from('shopping_lists')
        .select(_select)
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<ShoppingList?> byId(String id) async {
    final row = await _client
        .from('shopping_lists')
        .select(_select)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<ShoppingList> create(String name, {double? budget}) async {
    final row = await _client
        .from('shopping_lists')
        .insert({'user_id': _userId, 'name': name, 'budget': budget})
        .select()
        .single();
    return ShoppingList.fromJson(row);
  }

  @override
  Future<void> rename(String id, String name, {double? budget}) => _client
      .from('shopping_lists')
      .update({
        'name': name,
        'budget': budget,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', id);

  @override
  Future<void> delete(String id) =>
      _client.from('shopping_lists').delete().eq('id', id);

  @override
  Future<ShoppingList> duplicate(String id) async {
    final source = await byId(id);
    if (source == null) throw StateError('List $id not found');
    final copy = await create('${source.name} (copy)', budget: source.budget);
    if (source.items.isNotEmpty) {
      await _client.from('shopping_items').insert([
        for (final i in source.items)
          {
            'list_id': copy.id,
            'product_id': i.productId,
            'name': i.name,
            'quantity': i.quantity,
            'unit': i.unit,
            'notes': i.notes,
          },
      ]);
    }
    return (await byId(copy.id))!;
  }

  @override
  Future<void> addItem(String listId, ShoppingItem item) =>
      _client.from('shopping_items').insert({
        'list_id': listId,
        'product_id': item.productId,
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'notes': item.notes,
      });

  @override
  Future<void> updateItem(ShoppingItem item) => _client
      .from('shopping_items')
      .update({
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'checked': item.checked,
        'notes': item.notes,
      })
      .eq('id', item.id);

  @override
  Future<void> removeItem(String listId, String itemId) =>
      _client.from('shopping_items').delete().eq('id', itemId);
}

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  if (AppConfig.isDemoMode) {
    return DemoShoppingListRepository(ref.watch(localStoreProvider));
  }
  return SupabaseShoppingListRepository(ref.watch(supabaseClientProvider));
});
