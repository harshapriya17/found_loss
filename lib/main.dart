import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'local_storage/hive_service.dart';
import 'views/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and Storage Boxes
  await HiveService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lost & Found Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
