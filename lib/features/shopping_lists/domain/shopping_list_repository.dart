import 'shopping_list.dart';

abstract interface class ShoppingListRepository {
  Future<List<ShoppingList>> lists();

  Future<ShoppingList?> byId(String id);

  Future<ShoppingList> create(String name, {double? budget});

  Future<void> rename(String id, String name, {double? budget});

  Future<void> delete(String id);

  Future<ShoppingList> duplicate(String id);

  Future<void> addItem(String listId, ShoppingItem item);

  /// [fieldsEdit] marks a name/quantity/unit/notes edit (vs a checkbox
  /// toggle). Implementations that queue offline writes replay only the
  /// columns the caller actually changed — a queued snapshot must never
  /// clobber newer edits to the other columns.
  Future<void> updateItem(ShoppingItem item, {bool fieldsEdit = false});

  Future<void> removeItem(String listId, String itemId);
}
