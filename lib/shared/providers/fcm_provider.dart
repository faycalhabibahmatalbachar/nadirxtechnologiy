import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final flutterLocalNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  if (kIsWeb) return null;
  final messaging = ref.watch(firebaseMessagingProvider);
  return await messaging.getToken();
});

final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  if (kIsWeb) return false;
  final messaging = ref.watch(firebaseMessagingProvider);
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized;
});

Future<void> initializeNotifications() async {
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  await FlutterLocalNotificationsPlugin().initialize(initSettings);

  const androidChannel = AndroidNotificationChannel(
    'nadirx_channel',
    'NADIRX Technologie',
    description: 'Notifications de formation',
    importance: Importance.max,
  );

  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}

Future<void> showLocalNotification({
  required String title,
  required String body,
}) async {
  await FlutterLocalNotificationsPlugin().show(
    0,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'nadirx_channel',
        'NADIRX Technologie',
        channelDescription: 'Notifications de formation',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF00FF88),
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}
