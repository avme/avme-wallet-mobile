import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotification
{
  static final PushNotification _pushNotification = PushNotification._internal();
  PushNotification._internal();

  static PushNotification getInstance() =>  _pushNotification;

  static const AndroidNotificationDetails debugChannel0 =
  AndroidNotificationDetails('0', 'debugChannel0',
    channelDescription: 'using this channel to test notifications',
    importance: Importance.max,
    priority: Priority.high,);

  static const  AndroidNotificationDetails debugChannel1 =
  AndroidNotificationDetails('1', 'debugChannel1',
    channelDescription: 'using this channel to test notifications',
    importance: Importance.max,
    priority: Priority.high,);

  static const  AndroidNotificationDetails debugChannel2 =
  AndroidNotificationDetails('2', 'debugChannel2',
    channelDescription: 'using this channel to test notifications',
    importance: Importance.max,
    priority: Priority.high,);

  static const  AndroidNotificationDetails debugChannel3 =
  AndroidNotificationDetails('3', 'debugChannel3',
    channelDescription: 'using this channel to test notifications',
    importance: Importance.max,
    priority: Priority.high,);

  static const  AndroidNotificationDetails debugChannel4 =
  AndroidNotificationDetails('4', 'debugChannel4',
    channelDescription: 'using this channel to test notifications',
    importance: Importance.max,
    priority: Priority.high,);

  static const  AndroidNotificationDetails debugChannel5 =
  AndroidNotificationDetails('5', 'debugChannel5',
    channelDescription: 'using this channel to test notifications',
    importance: Importance.max,
    priority: Priority.high,);

  static const  AndroidNotificationDetails alertChannel =
  AndroidNotificationDetails('10', 'Alert Channel',
    channelDescription: 'Display Alert notifications through App',
    importance: Importance.max,
    priority: Priority.high,);

  static const  AndroidNotificationDetails appChannel =
  AndroidNotificationDetails('11', 'App Channel',
    channelDescription: 'Display notifications through App',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,);
}