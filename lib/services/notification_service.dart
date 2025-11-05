import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Set local timezone
      final String timeZoneName = 'Asia/Kolkata'; // Change if needed
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);

      // Request permissions for iOS
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Request permissions for Android 13+
      final androidImpl = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      final permissionGranted = await androidImpl?.requestNotificationsPermission();
      print('Notification permission granted: $permissionGranted');
      
      // Request exact alarm permission for Android 14+ (API 34+)
      final exactAlarmGranted = await androidImpl?.requestExactAlarmsPermission();
      print('Exact alarm permission granted: $exactAlarmGranted');
    } catch (e) {
      print('Error initializing notifications: $e');
      rethrow;
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    bool isAlarm = false,
  }) async {
    try {
      final scheduledTime = _nextInstanceOfTime(hour, minute);
      print('Scheduling ${isAlarm ? "ALARM" : "notification"} ID:$id "$title" at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} -> $scheduledTime');
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            isAlarm ? 'wake_alarm_channel' : 'daily_routine_channel',
            isAlarm ? 'Wake Up Alarms' : 'Daily Routine Notifications',
            channelDescription: isAlarm 
                ? 'Wake up alarm with morning alarm sound' 
                : 'Notifications for daily routine events',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            sound: isAlarm 
                ? const RawResourceAndroidNotificationSound('morning_alarm')
                : null,
            enableVibration: true,
            fullScreenIntent: isAlarm,
            category: isAlarm ? AndroidNotificationCategory.alarm : null,
            autoCancel: false,
            ongoing: false,
            visibility: NotificationVisibility.public,
            ticker: title,
          ),
          iOS: DarwinNotificationDetails(
            sound: isAlarm ? 'morning_alarm.aiff' : null,
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
      );
      
      print('Successfully scheduled ${isAlarm ? "ALARM" : "notification"} ID:$id');
    } catch (e) {
      print('ERROR scheduling ${isAlarm ? "ALARM" : "notification"} ID:$id: $e');
      rethrow;
    }
  }

  Future<void> scheduleWakeUpAlarm({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await scheduleDailyNotification(
      id: id,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      isAlarm: true,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('All notifications cancelled');
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('Notification $id cancelled');
  }

  // Test notification for immediate feedback
  Future<void> showTestNotification() async {
    try {
      await _notifications.show(
        99999,
        '🔔 Test Notification',
        'If you see this, notifications are working correctly!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notifications to verify setup',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            ticker: 'Test',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print('Test notification shown successfully');
    } catch (e) {
      print('Error showing test notification: $e');
      rethrow;
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImpl = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImpl != null) {
        final bool? enabled = await androidImpl.areNotificationsEnabled();
        print('Notifications enabled status: $enabled');
        return enabled ?? false;
      }
      
      return true; // Assume enabled on other platforms
    } catch (e) {
      print('Error checking notification status: $e');
      return false;
    }
  }

  // Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
