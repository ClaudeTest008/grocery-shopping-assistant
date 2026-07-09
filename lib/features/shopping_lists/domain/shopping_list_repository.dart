import 'shopping_list.dart';

abstract interface class ShoppingListRepository {
  Future<List<ShoppingList>> lists();

  Future<ShoppingList?> byId(String id);

  Future<ShoppingList> create(String name, {double? budget});

  Future<void> rename(String id, String name, {double? budget});

  Future<void> delete(String id);

  Future<ShoppingList> duplicate(String id);

  Future<void> addItem(String listId, ShoppingItem item);

  Future<void> updateItem(ShoppingItem item);

  Future<void> removeItem(String listId, String itemId);
}
