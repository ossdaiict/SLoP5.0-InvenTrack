// lib/services/notification_service.dart

import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/grocery_item.dart';
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle your background navigation or data processing here.
  // This function must be a top-level function or a static method.
  print('Notification Tapped in Background: ${notificationResponse.payload}');
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // A stream to broadcast notification responses to the UI.
  final StreamController<String?> onNotificationTap = StreamController<String?>.broadcast();

  Future<void> init() async {
    // Request notification permissions on Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );


    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // Handles taps when the app is in the foreground or background (but not terminated).
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap.add(response.payload);
      },
      // Handles taps when the app is terminated. [6, 8]
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    tz.initializeTimeZones();
  }

  Future<void> scheduleExpiryNotification(GroceryItem item) async {
    if (item.id == null) return; // Ensure item has an ID.

    await flutterLocalNotificationsPlugin.cancel(item.id!);

    final DateTime scheduledDate = item.expiryDate.subtract(const Duration(days: 1));
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      8, // 8:00 AM
    );

    if (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expiry_channel_id',
      'Expiry Reminders',
      channelDescription: 'Reminders for expiring grocery items.',
      importance: Importance.high,
      priority: Priority.high, // Ensure visibility
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      item.id!,
      'Item Expiring Soon: ${item.name}', // Improved Title
      'Your ${item.name} (${item.quantity.toStringAsFixed(0)} ${item.unit}) is expiring tomorrow!', // Improved Body
      scheduledTZDate,
      platformDetails,
      payload: 'item_id_${item.id}', // Pass the item ID as a payload
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Clean up the stream controller.
  void dispose() {
    onNotificationTap.close();
  }
}
