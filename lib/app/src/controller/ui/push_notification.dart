import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

///Thank @JohannesMilke's tutorial/github
class PushNotification
{
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final BehaviorSubject onNotifications = BehaviorSubject<String>();

  static Future _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'id',
        'name',
        channelDescription: 'description',
        priority: Priority.max,
        importance: Importance.max
      ),
      iOS: IOSNotificationDetails()
    );
  }

  static Future init({bool initSchedule = false}) async
  {
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      android: initializationSettingsAndroid
    );

    await _notifications.initialize(
      settings,
      onSelectNotification: (String? payload) async
      {
        if(payload != null && payload.isNotEmpty) {
          onNotifications.add(payload);
        }
      }
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload
  }) async {
    return _notifications.show(id, title, body, await _notificationDetails(), payload: payload);
  }
}