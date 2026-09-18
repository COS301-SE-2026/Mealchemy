import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

import '../models/cook_timer.dart';

enum CookTimerAlertStatus {
  scheduled,
  notificationsDenied,
  exactAlarmDenied,
  unsupported,
  failed,
}

abstract class CookTimerNotificationService {
  Future<CookTimerAlertStatus> schedule(CookTimer timer);
  Future<void> cancel(int notificationId);
}

class FlutterLocalNotificationsCookTimerService
    implements CookTimerNotificationService {
  FlutterLocalNotificationsCookTimerService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'cook_timers';
  static const _channelName = 'Cooking timers';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    time_zone_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_mealchemy_timer'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<CookTimerAlertStatus> schedule(CookTimer timer) async {
    if (kIsWeb) return CookTimerAlertStatus.unsupported;

    try {
      await _initialize();
      final permissionStatus = await _requestPermissions();
      if (permissionStatus != CookTimerAlertStatus.scheduled) {
        return permissionStatus;
      }

      await _plugin.zonedSchedule(
        id: timer.notificationId,
        title: 'Cooking timer finished',
        body: timer.label,
        scheduledDate: time_zone.TZDateTime.from(
          timer.endsAt.toUtc(),
          time_zone.UTC,
        ),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Alerts when a cooking timer finishes',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'cook_timer:${timer.notificationId}',
      );
      return CookTimerAlertStatus.scheduled;
    } catch (_) {
      return CookTimerAlertStatus.failed;
    }
  }

  Future<CookTimerAlertStatus> _requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return CookTimerAlertStatus.unsupported;

      final notificationsAllowed =
          await android.requestNotificationsPermission() ?? false;
      if (!notificationsAllowed) {
        return CookTimerAlertStatus.notificationsDenied;
      }

      var exactAlarmAllowed =
          await android.canScheduleExactNotifications() ?? false;
      if (!exactAlarmAllowed) {
        exactAlarmAllowed =
            await android.requestExactAlarmsPermission() ?? false;
      }
      return exactAlarmAllowed
          ? CookTimerAlertStatus.scheduled
          : CookTimerAlertStatus.exactAlarmDenied;
    }

    if (Platform.isIOS) {
      final allowed = await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: false, sound: true) ??
          false;
      return allowed
          ? CookTimerAlertStatus.scheduled
          : CookTimerAlertStatus.notificationsDenied;
    }

    if (Platform.isMacOS) {
      final allowed = await _plugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: false, sound: true) ??
          false;
      return allowed
          ? CookTimerAlertStatus.scheduled
          : CookTimerAlertStatus.notificationsDenied;
    }

    return CookTimerAlertStatus.unsupported;
  }

  @override
  Future<void> cancel(int notificationId) async {
    if (kIsWeb) return;
    await _initialize();
    await _plugin.cancel(id: notificationId);
  }
}
