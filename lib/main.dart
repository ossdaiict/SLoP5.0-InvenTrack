// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/grocery_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

final NotificationService notificationService = NotificationService();
  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notificationService.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GroceryProvider(),
      child: const GrocyTrackApp(),
    ),
  );
}

class GrocyTrackApp extends StatelessWidget {
  const GrocyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrocyTrack Offline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start with the main screen
    );
  }
}
