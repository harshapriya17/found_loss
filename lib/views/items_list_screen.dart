import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/item_controller.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';
import '../utils/debouncer.dart';
import '../widgets/item_card.dart';
import '../widgets/empty_state.dart';
import 'item_details_screen.dart';
import 'report_item_screen.dart';

class ItemsListScreen extends StatefulWidget {
  final int initialIndex;
  final bool isEmbedded;

  const ItemsListScreen({
    super.key,
    this.initialIndex = 0,
    this.isEmbedded = false,
  });

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ItemController controller = Get.find<ItemController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(widget.isEmbedded ? 'Reports Feed' : 'Items Feed'),
        automaticallyImplyLeading: !widget.isEmbedded,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.accentColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.search_off), text: 'Lost Items'),
            Tab(icon: Icon(Icons.youtube_searched_for), text: 'Found Items'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ItemsTabView(type: 'lost', controller: controller),
          _ItemsTabView(type: 'found', controller: controller),
        ],
      ),
      floatingActionButton: widget.isEmbedded ? null : FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          final currentType = _tabController.index == 0 ? 'lost' : 'found';
          Get.to(() => ReportItemScreen(type: currentType));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ItemsTabView extends StatefulWidget {
  final String type;
  final ItemController controller;

  const _ItemsTabView({required this.type, required this.controller});

  @override
  State<_ItemsTabView> createState() => _ItemsTabViewState();
}

class _ItemsTabViewState extends State<_ItemsTabView> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  final List<String> categories = [
    'All',
    'Electronics',
    'Documents',
    'Keys',
    'Clothing & Accessories',
    'Books & Stationery',
    'Others'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      widget.controller.loadMore(widget.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              _debouncer.run(() {
                widget.controller.onSearchOrFilterChanged(val, widget.controller.selectedCategory.value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  widget.controller.onSearchOrFilterChanged('', widget.controller.selectedCategory.value);
                },
              ),
            ),
          ),
        ),

        // Categories
        Container(
          height: 54,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Obx(() {
                final isSelected = widget.controller.selectedCategory.value == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newCat = selected ? cat : 'All';
                      widget.controller.onSearchOrFilterChanged(widget.controller.searchQuery.value, newCat);
                    },
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              });
            },
          ),
        ),
        const Divider(height: 1, thickness: 1),

        // List
        Expanded(
          child: Obx(() {
            final items = widget.type == 'lost' 
                ? widget.controller.displayedLostItems 
                : widget.controller.displayedFoundItems;
            
            final hasMore = widget.type == 'lost' 
                ? widget.controller.hasMoreLost.value 
                : widget.controller.hasMoreFound.value;

            if (items.isEmpty) {
              return EmptyState(
                title: widget.controller.searchQuery.value.isNotEmpty || widget.controller.selectedCategory.value != 'All' 
                    ? 'No matching results' 
                    : 'No reports yet',
                subtitle: 'Try different keywords or check back later.',
                icon: Icons.inbox,
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: items.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < items.length) {
                  final item = items[index];
                  return ItemCard(
                    key: ValueKey(item.id),
                    item: item,
                    onTap: () => Get.to(() => ItemDetailsScreen(item: item)),
                    onActionSelected: (value) {
                      if (value == 'view') {
                        Get.to(() => ItemDetailsScreen(item: item));
                      } else if (value == 'edit') {
                        Get.to(() => ReportItemScreen(type: item.type, item: item));
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, item);
                      }
                    },
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          }),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, ItemModel item) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Delete'),
        content: Text('Delete the report for "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              widget.controller.deleteItem(item.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusLost),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
