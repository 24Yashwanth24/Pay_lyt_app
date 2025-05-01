import 'package:easy_notifications/easy_notifications.dart';

class NotificationService {
  // Initialize notifications
  static Future<void> init() async {
    await EasyNotifications.init();
  }

  // Show a simple notification
  static Future<void> showNotification(String title, String body) async {
    await EasyNotifications.showMessage(title: title, body: body);
  }

  // Schedule a notification for later
  static Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    await EasyNotifications.scheduleMessage(
      title: title,
      body: body,
      scheduledDate: scheduledTime,
    );
  }
}
