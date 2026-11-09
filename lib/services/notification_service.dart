import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../core/firebase/firebase_options.dart';
import 'preferences_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class NotificationService {
  NotificationService._();

  static final ValueNotifier<RemoteMessage?> foregroundMessage =
      ValueNotifier<RemoteMessage?>(null);
  static bool _initialized = false;

  static bool get _isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> initialize() async {
    if (!_isSupportedPlatform || _initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    final enabled = await PreferencesService.getNotificationsEnabled();
    await setEnabled(enabled, requestPermission: enabled);

    FirebaseMessaging.onMessage.listen((message) {
      foregroundMessage.value = message;
    });
  }

  static Future<void> unsubscribeForLogout() async {
    if (!_isSupportedPlatform) return;
    await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
  }

  static Future<void> setEnabled(
    bool enabled, {
    bool requestPermission = true,
  }) async {
    await PreferencesService.setNotificationsEnabled(enabled);
    if (!_isSupportedPlatform) return;

    final messaging = FirebaseMessaging.instance;
    if (enabled) {
      if (requestPermission) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      await messaging.subscribeToTopic('all_users');
    } else {
      await messaging.unsubscribeFromTopic('all_users');
    }
  }
}
