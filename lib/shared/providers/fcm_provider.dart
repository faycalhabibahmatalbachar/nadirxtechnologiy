import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

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

Future<String?> _downloadImageToTempFile(String url) async {
  try {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final client = HttpClient();
    final req = await client.getUrl(uri);
    final res = await req.close();
    if (res.statusCode < 200 || res.statusCode >= 300) return null;

    final bytes = await consolidateHttpClientResponseBytes(res);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/nadirx_notif_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } catch (_) {
    return null;
  }
}

Future<bool> requestPushPermissionIfNeeded() async {
  if (kIsWeb) return false;
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized;
}

Future<void> registerFcmForegroundHandler() async {
  if (kIsWeb) return;

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? '';
    final body = notification.body ?? '';
    if (title.trim().isEmpty && body.trim().isEmpty) return;

    final dataPhotoUrl = (message.data['photo_url'] ?? '').toString().trim();
    final notifPhotoUrl =
        notification.android?.imageUrl ?? notification.apple?.imageUrl;
    final photoUrl = dataPhotoUrl.isNotEmpty ? dataPhotoUrl : notifPhotoUrl;

    final imagePath = photoUrl == null || photoUrl.toString().trim().isEmpty
        ? null
        : await _downloadImageToTempFile(photoUrl.toString());

    final androidDetails = imagePath == null
        ? const AndroidNotificationDetails(
            'nadirx_channel',
            'NADIRX Technologie',
            channelDescription: 'Notifications de formation',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFF00FF88),
            icon: '@mipmap/ic_launcher',
          )
        : AndroidNotificationDetails(
            'nadirx_channel',
            'NADIRX Technologie',
            channelDescription: 'Notifications de formation',
            importance: Importance.max,
            priority: Priority.high,
            color: const Color(0xFF00FF88),
            icon: '@mipmap/ic_launcher',
            styleInformation: BigPictureStyleInformation(
              FilePathAndroidBitmap(imagePath),
              largeIcon: FilePathAndroidBitmap(imagePath),
              contentTitle: title,
              summaryText: body,
            ),
          );

    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  });
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}
