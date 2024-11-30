import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsManager {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false; // To track initialization state

  LocalNotificationsManager() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    if (_isInitialized) return; // Avoid multiple initializations

    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    try {
      await _notificationsPlugin.initialize(initializationSettings);
      _isInitialized = true;
      print("Local notifications initialized successfully.");
    } catch (error) {
      print("Error initializing notifications: $error");
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String channelId = 'default_channel',
    String channelName = 'Default Notifications',
    String? channelDescription,
    int id = 0,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription ?? 'General notifications',
        importance: importance,
        priority: priority,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(id, title, body, notificationDetails);
      print("Notification displayed: $title");
    } catch (error) {
      print("Error showing notification: $error");
    }
  }
}