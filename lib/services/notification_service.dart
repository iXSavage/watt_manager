import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();

    const initSettingsAndroid =
    AndroidInitializationSettings('watt_manager');

    // Request permission for Android 13+
    await _requestPermission();

    const initSettingsIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIos,
    );

    await notificationsPlugin.initialize(settings: initSettings);
    _isInitialized = true;
  }

  Future<void> _requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // If permanently denied, open app settings
    if (await Permission.notification.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'watt_manager_channel',
        'Watt Manager Alerts',
        channelDescription: 'Watt Manager Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'watt_manager'
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    return notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async {
    await notificationsPlugin.cancel(id:id);
  }

  Future<void> cancelAll() async {
    await notificationsPlugin.cancelAll();
  }
}