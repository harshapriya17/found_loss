import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/item_controller.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';
import '../widgets/status_tracker.dart';
import 'report_item_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final ItemModel item;
  final ItemController controller = Get.find<ItemController>();

  ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          // Using a single Obx for all actions to keep it clean and prevent layout issues
          Obx(() {
            // Accessing the reactive list to ensure this widget updates if the item changes
            final currentItem = controller.allItems.firstWhere(
              (element) => element.id == item.id,
              orElse: () => item,
            );

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Get.to(() => ReportItemScreen(type: currentItem.type, item: currentItem)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(context, currentItem),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        // Re-finding the item from the reactive master list
        final current = controller.allItems.firstWhere(
          (element) => element.id == item.id,
          orElse: () => item,
        );
        final isLost = current.type == 'lost';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Image
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: _buildHeroImage(current.imagePath),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            current.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMMM yyyy').format(current.date),
                          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      current.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 20),

                    // Status Tracker
                    StatusTracker(item: current),
                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardShadowDecoration,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.location_on,
                            iconColor: AppTheme.statusLost,
                            title: isLost ? 'Last Seen Location' : 'Found Location',
                            value: current.location,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.phone,
                            iconColor: AppTheme.primaryColor,
                            title: 'Contact Number',
                            value: current.contactNumber,
                            isPhone: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardShadowDecoration,
                      child: Text(
                        current.description.isNotEmpty ? current.description : 'No description provided.',
                        style: const TextStyle(fontSize: 15, color: AppTheme.textDark, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    _buildStatusActionButton(current),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Center(child: Icon(Icons.image, size: 80, color: AppTheme.primaryLight));
    }
    final file = File(imagePath);
    if (!file.existsSync()) {
      return const Center(child: Icon(Icons.broken_image, size: 80, color: AppTheme.primaryLight));
    }
    return Image.file(file, fit: BoxFit.cover, width: double.infinity);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    bool isPhone = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.textDark, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (isPhone)
          IconButton(
            icon: const Icon(Icons.phone_forwarded, color: AppTheme.primaryColor),
            onPressed: () => Get.snackbar('Contact', 'Call $value', snackPosition: SnackPosition.BOTTOM),
          ),
      ],
    );
  }

  Widget _buildStatusActionButton(ItemModel current) {
    if (current.status == 'Returned') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.statusReturned.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.statusReturned.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppTheme.statusReturned),
            SizedBox(width: 10),
            Text('Item Returned', style: TextStyle(color: AppTheme.statusReturned, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      );
    }

    String btnText = '';
    String targetStatus = '';
    Color btnColor = AppTheme.primaryColor;

    if (current.type == 'lost') {
      if (current.status == 'Lost') {
        btnText = 'Mark as Matched';
        targetStatus = 'Matched';
        btnColor = AppTheme.statusMatched;
      } else {
        btnText = 'Mark as Returned';
        targetStatus = 'Returned';
        btnColor = AppTheme.statusReturned;
      }
    } else {
      if (current.status == 'Found') {
        btnText = 'Mark as Claimed';
        targetStatus = 'Claimed';
        btnColor = AppTheme.statusMatched;
      } else {
        btnText = 'Mark as Returned';
        targetStatus = 'Returned';
        btnColor = AppTheme.statusReturned;
      }
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: btnColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () => controller.updateStatus(current.id, targetStatus),
        child: Text(btnText, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ItemModel currentItem) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete report for "${currentItem.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.deleteItem(currentItem.id);
              Get.back();
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
