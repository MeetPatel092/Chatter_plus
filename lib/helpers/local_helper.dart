import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;

class LocalHelper {
  LocalHelper._();
  static final LocalHelper localHelper = LocalHelper._();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings("mipmap/ic_launcher");
    DarwinInitializationSettings iOSInitializationSettings =
        const DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showeSimpleNotification(
      {required String title, required String body}) async {
    await initNotification();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
    );
    DarwinNotificationDetails iSONotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iSONotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
        1, title, body, notificationDetails);
  }

  Future<void> showSchedulNotification() async {
    await initNotification();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
    );
    DarwinNotificationDetails iSONotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iSONotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      "Scheduled  Title",
      "Hy how are you",
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showBigPictureNotification() async {
    await initNotification();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("mitmap/ic_launcher"),
      ),
    );
    DarwinNotificationDetails iSONotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iSONotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
        1, "Simple Title", " Hello Word", notificationDetails);
  }
}
