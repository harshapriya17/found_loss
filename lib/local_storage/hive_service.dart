import 'package:hive_flutter/hive_flutter.dart';
import '../models/item_model.dart';

class HiveService {
  static const String boxName = 'items_box';

  /// Initializes Hive and opens the required boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  /// Gets the instance of the items box
  Box _getBox() => Hive.box(boxName);

  /// Retrieves all items from the box
  List<ItemModel> getAllItems() {
    final box = _getBox();
    final List<ItemModel> items = [];
    
    for (var key in box.keys) {
      final data = box.get(key);
      if (data is Map) {
        items.add(ItemModel.fromMap(data));
      }
    }
    return items;
  }

  /// Adds or updates an item in the box
  Future<void> saveItem(ItemModel item) async {
    final box = _getBox();
    await box.put(item.id, item.toMap());
  }

  /// Deletes an item from the box
  Future<void> deleteItem(String id) async {
    final box = _getBox();
    await box.delete(id);
  }

  /// Clears all data from the box (for testing/reset)
  Future<void> clearAll() async {
    final box = _getBox();
    await box.clear();
  }
}
