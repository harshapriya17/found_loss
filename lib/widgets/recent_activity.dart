import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/item_model.dart';
import '../views/item_details_screen.dart';
import '../theme/app_theme.dart';
import 'item_card.dart';

class RecentActivity extends StatelessWidget {
  final List<ItemModel> items;

  const RecentActivity({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardShadowDecoration,
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 40, color: AppTheme.textMuted),
              SizedBox(height: 8),
              Text(
                'No recent reports',
                style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Reported items will appear here',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return ItemCard(
          item: item,
          onTap: () => Get.to(() => ItemDetailsScreen(item: item)),
        );
      }).toList(),
    );
  }
}
