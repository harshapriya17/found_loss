import 'package:get/get.dart';
import '../models/item_model.dart';
import '../local_storage/hive_service.dart';

class ItemController extends GetxController {
  final HiveService _storage = HiveService();

  // Master list is now reactive (RxList) to allow Obx to listen to changes globally
  final RxList<ItemModel> allItems = <ItemModel>[].obs;
  
  // paginated and filtered UI lists
  final RxList<ItemModel> displayedLostItems = <ItemModel>[].obs;
  final RxList<ItemModel> displayedFoundItems = <ItemModel>[].obs;
  
  // Pagination state
  final int pageSize = 10;
  final RxInt currentLostPage = 1.obs;
  final RxInt currentFoundPage = 1.obs;
  final RxBool hasMoreLost = true.obs;
  final RxBool hasMoreFound = true.obs;
  
  // Search and Filter state
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  // Loading states
  final RxBool isLoading = true.obs;
  final RxBool isFetchingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      final items = _storage.getAllItems();
      
      // Sort by date descending
      items.sort((a, b) => b.date.compareTo(a.date));
      
      allItems.assignAll(items);
      resetAndRefresh();
    } catch (e) {
      Get.log("Error loading items: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void resetAndRefresh() {
    currentLostPage.value = 1;
    currentFoundPage.value = 1;
    _updateDisplayedItems('lost');
    _updateDisplayedItems('found');
  }

  void onSearchOrFilterChanged(String query, String category) {
    searchQuery.value = query;
    selectedCategory.value = category;
    resetAndRefresh();
  }

  void loadMore(String type) {
    if (isFetchingMore.value) return;
    
    if (type == 'lost' && !hasMoreLost.value) return;
    if (type == 'found' && !hasMoreFound.value) return;

    isFetchingMore.value = true;
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (type == 'lost') {
        currentLostPage.value++;
      } else {
        currentFoundPage.value++;
      }
      _updateDisplayedItems(type);
      isFetchingMore.value = false;
    });
  }

  void _updateDisplayedItems(String type) {
    final filtered = allItems.where((item) {
      if (item.type != type) return false;
      
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          item.location.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      final matchesCategory = selectedCategory.value == 'All' || item.category == selectedCategory.value;
      
      return matchesSearch && matchesCategory;
    }).toList();

    final page = type == 'lost' ? currentLostPage.value : currentFoundPage.value;
    final endIndex = page * pageSize;
    
    final pagedItems = filtered.take(endIndex).toList();
    
    if (type == 'lost') {
      displayedLostItems.assignAll(pagedItems);
      hasMoreLost.value = pagedItems.length < filtered.length;
    } else {
      displayedFoundItems.assignAll(pagedItems);
      hasMoreFound.value = pagedItems.length < filtered.length;
    }
  }

  // CRUD updates now refresh the UI lists automatically
  Future<void> addItem(ItemModel item) async {
    await _storage.saveItem(item);
    allItems.insert(0, item);
    resetAndRefresh();
  }

  Future<void> updateItem(ItemModel updatedItem) async {
    await _storage.saveItem(updatedItem);
    final index = allItems.indexWhere((element) => element.id == updatedItem.id);
    if (index != -1) {
      allItems[index] = updatedItem;
    }
    resetAndRefresh();
  }

  Future<void> deleteItem(String id) async {
    await _storage.deleteItem(id);
    allItems.removeWhere((element) => element.id == id);
    resetAndRefresh();
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final index = allItems.indexWhere((element) => element.id == id);
    if (index != -1) {
      final updated = allItems[index].copyWith(status: newStatus);
      await updateItem(updated);
    }
  }

  // Dashboard Stats
  int get totalLostActive => allItems.where((item) => item.type == 'lost' && item.status != 'Returned').length;
  int get totalFoundActive => allItems.where((item) => item.type == 'found' && item.status != 'Returned').length;
  int get totalReturned => allItems.where((item) => item.status == 'Returned').length;
}
