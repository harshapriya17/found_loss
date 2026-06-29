import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/item_controller.dart';
import 'dashboard_screen.dart';
import 'items_list_screen.dart';
import 'report_item_screen.dart';
import '../theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final ItemController controller = Get.put(ItemController());
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ItemsListScreen(initialIndex: 0, isEmbedded: true),
    const ItemsListScreen(initialIndex: 1, isEmbedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_off_outlined),
            activeIcon: Icon(Icons.search_off),
            label: 'Lost Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.youtube_searched_for_outlined),
            activeIcon: Icon(Icons.youtube_searched_for),
            label: 'Found Items',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () => _showReportOptions(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What would you like to report?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    title: 'Lost Item',
                    icon: Icons.search_off,
                    color: AppTheme.statusLost,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ReportItemScreen(type: 'lost'));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionCard(
                    title: 'Found Item',
                    icon: Icons.youtube_searched_for,
                    color: AppTheme.statusFound,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ReportItemScreen(type: 'found'));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
