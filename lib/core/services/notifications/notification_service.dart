import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit =
    DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(
      settings : settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'yellowspot_channel',
      'Yellowspot Notifications',
      channelDescription: 'Real-time updates for parking and community',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id : id,
      title : title,
      body : body,
      notificationDetails : notificationDetails,
    );
  }
}