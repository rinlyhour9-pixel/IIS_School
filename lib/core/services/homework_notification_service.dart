import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:schoolapp/firebase_options.dart';
import 'package:schoolapp/core/services/fcm_token_sync_service.dart';
import 'package:schoolapp/routes.dart';
import 'package:schoolapp/core/libraries/shared_preferences.dart';
import 'package:schoolapp/core/services/class_topic_subscription_service.dart';

const String _notificationIcon = 'ic_notification';
const String _typeHomework = 'homework';
const String _typeActivity = 'activity';
const String _typeAttendance = 'attendance';
const String _typeReminder = 'reminder';
const String _typeAnnouncement = 'announcement';

const AndroidNotificationChannel _homeworkChannel = AndroidNotificationChannel(
  'homework_channel',
  'Homework Notifications',
  description: 'Alerts students when new homework is assigned.',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('homework_notification'),
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

class HomeworkNotificationService {
  HomeworkNotificationService._();

  static final HomeworkNotificationService instance =
      HomeworkNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _enabledKey = 'notifications_enabled';
  bool _initialized = false;

  Future<bool> isEnabled() async {
    final raw =
        (await SharedPreferencesManager.get(_enabledKey) ?? 'true')
            .toString()
            .trim()
            .toLowerCase();
    return raw != 'false' && raw != '0';
  }

  Future<void> setEnabled(bool enabled) async {
    await SharedPreferencesManager.setValue(_enabledKey, enabled.toString());
    if (!enabled) {
      await _localNotifications.cancelAll();
      await ClassTopicSubscriptionService.instance.clearSubscription();
      return;
    }
    await FirebaseMessaging.instance.requestPermission();
    await FcmTokenSyncService.instance.syncCurrentTokenIfAuthenticated(
      force: true,
    );
    await ClassTopicSubscriptionService.instance.syncSelectedClassTopic();
  }

  Future<void> initialize() async {
    if (_initialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings(_notificationIcon),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidPlugin?.createNotificationChannel(_homeworkChannel);
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final macOSPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
    await macOSPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    _initialized = true;
  }

  Future<void> handleInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  Future<void> showTestHomeworkNotification() async {
    await initialize();
    if (!await isEnabled()) return;
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'New Homework',
      'Please check your class work.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'homework_channel',
          'Homework Notifications',
          channelDescription: 'Alerts students when new homework is assigned.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('homework_notification'),
          icon: _notificationIcon,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'homework_notification.wav',
        ),
      ),
      payload: _typeHomework,
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!await isEnabled()) return;
    final notificationType = _notificationType(message);
    debugPrint(
      'Foreground FCM received: '
      'title="${message.notification?.title ?? message.data['title'] ?? ''}", '
      'body="${message.notification?.body ?? message.data['body'] ?? ''}", '
      'data=${message.data}, '
      'type=$notificationType',
    );
    if (notificationType == null) return;

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ??
          message.data['title']?.toString() ?? 
          _defaultTitle(notificationType),
      message.notification?.body ??
          message.data['body']?.toString() ??
          _defaultBody(notificationType),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'homework_channel',
          'Homework Notifications',
          channelDescription: 'Alerts students when new homework is assigned.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('homework_notification'),
          icon: _notificationIcon,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'homework_notification.wav',
        ),
      ),
      payload: notificationType,
    );
    debugPrint(
      'Foreground local notification shown for $notificationType message.',
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    unawaited(_openScreenForType(response.payload));
  }

  void _handleMessageTap(RemoteMessage message) {
    unawaited(_openScreenForType(_notificationType(message)));
  }

  String? _notificationType(RemoteMessage message) {
    final type = (message.data['type'] ?? '').toString().trim().toLowerCase();
    final category =
        (message.data['category'] ?? '').toString().trim().toLowerCase();
    final title =
        (message.notification?.title ?? message.data['title'] ?? '')
            .toString()
            .toLowerCase();

    if (_matchesType(type, category, title, _typeAttendance, const [
      'atterndance',
      'attendance',
      'check in',
      'check-in',
      'absent',
      'late',
    ])) {
      return _typeAttendance;
    }
    if (_matchesType(type, category, title, _typeActivity, const [
      'activity',
    ])) {
      return _typeActivity;
    }
    if (_matchesType(type, category, title, _typeHomework, const [
      'homework',
    ])) {
      return _typeHomework;
    }
    if (_matchesType(type, category, title, _typeReminder, const [
      'reminder',
      'remider',
    ])) {
      return _typeReminder;
    }
    if (_matchesType(type, category, title, _typeAnnouncement, const [
      'announcement',
      'notice',
    ])) {
      return _typeAnnouncement;
    }
    return _typeAnnouncement;
  }

  String _defaultTitle(String type) {
    switch (type) {
      case _typeAttendance:
        return 'Attendance Update';
      case _typeActivity:
        return 'New Class Activity';
      case _typeHomework:
        return 'New Homework';
      case _typeReminder:
        return 'School Reminder';
      case _typeAnnouncement:
      default:
        return 'School Announcement';
    }
  }

  String _defaultBody(String type) {
    switch (type) {
      case _typeAttendance:
        return 'Your attendance information has been updated.';
      case _typeActivity:
        return 'You have a new class activity.';
      case _typeHomework:
        return 'You have a new homework assignment.';
      case _typeReminder:
        return 'You have a new reminder.';
      case _typeAnnouncement:
      default:
        return 'You have a new school announcement.';
    }
  }

  bool _matchesType(
    String type,
    String category,
    String title,
    String expected,
    List<String> hints,
  ) {
    if (type == expected || category == expected) {
      return true;
    }
    for (final hint in hints) {
      if (type == hint || category == hint || title.contains(hint)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _openScreenForType(String? type) async {
    switch (type) {
      case _typeAttendance:
        await Get.toNamed(Routes.attendance);
        break;
      case _typeActivity:
        await Get.toNamed(Routes.activity);
        break;
      case _typeHomework:
        await Get.toNamed(Routes.homework);
        break;
      case _typeReminder:
      case _typeAnnouncement:
      default:
        await Get.toNamed(Routes.notification);
        break;
    }
  }
}
