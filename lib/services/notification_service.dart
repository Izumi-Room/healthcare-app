import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<void> showReminderPreview(String title, String body) async {
    const android = AndroidNotificationDetails(
      'vitatree_reminders',
      'VitaTree Reminders',
      channelDescription: 'Pengingat tidur dan bangun VitaTree',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      1,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }
}
