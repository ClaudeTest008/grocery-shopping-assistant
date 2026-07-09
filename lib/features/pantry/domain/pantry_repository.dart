import 'pantry_item.dart';

abstract interface class PantryRepository {
  Future<List<PantryItem>> items();

  Future<void> upsert(PantryItem item);

  Future<void> remove(String id);
}
