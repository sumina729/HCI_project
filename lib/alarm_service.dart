import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> scheduleAlarm({
  required int id,
  required TimeOfDay time,
  required String message,
}) async {
  final now = DateTime.now();
  final scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

  final tzScheduled = tz.TZDateTime.from(
    scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate,
    tz.local,
  );

  print('⏰ 알림 예약됨 [$id]: "$message" at ${tzScheduled.toLocal()}');


  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    '닥터메디',
    message,
    tzScheduled,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_channel', // ID
        'Alarm Notifications', // 이름
        channelDescription: '알림 테스트 및 약 복용 리마인더',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    ),

    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // 반복 알림 용
  );
}
