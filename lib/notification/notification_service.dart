import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    final String timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
      ),
    );

    final android = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted = await android?.requestNotificationsPermission();

    if (granted != false) {
      final prefs = await SharedPreferences.getInstance();

      // أول تشغيل فقط
      if (!prefs.containsKey("water_enabled")) {
        await prefs.setBool("water_enabled", true);
        await prefs.setInt("water_interval", 120);
      }

      final enabled = prefs.getBool("water_enabled") ?? true;
      final interval = prefs.getInt("water_interval") ?? 120;

      if (enabled) {
        await scheduleWaterReminders(interval);
      } else {
        await cancelAll();
      }
    }
  }

  static Future<bool> requestPermission() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted =
    await android?.requestNotificationsPermission();

    return granted ?? false;
  }

  static Future<void> scheduleWaterReminders(int intervalMinutes) async {
    await _notifications.cancelAll();

    final List<Future<void>> futures = [];

    for (int i = 1; i <= 50; i++) {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(
        Duration(minutes: intervalMinutes * i),
      );

      futures.add(
        _notifications.zonedSchedule(
          i,
          '💧 Time to Drink Water!',
          'Stay hydrated and keep your body performing at its best 💪',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'water_reminder',
              'Water Reminder',
              channelDescription: 'Water drinking reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: null,
        ),
      );
    }

    // انتظر انتهاء جدولة كل الإشعارات
    await Future.wait(futures);

    final pending = await _notifications.pendingNotificationRequests();
    debugPrint("Pending notifications: ${pending.length}");
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}