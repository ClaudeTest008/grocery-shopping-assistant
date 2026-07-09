import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Firebase Cloud Messaging wrapper.
///
/// Init is fully guarded: without google-services.json /
/// GoogleService-Info.plist the app runs normally with push disabled.
abstract final class NotificationService {
  static bool _available = false;
  static bool get isAvailable => _available;

  static final StreamController<RemoteMessage> _foreground =
      StreamController.broadcast();

  /// Foreground push messages (topic offers, price drops, reminders).
  static Stream<RemoteMessage> get onMessage => _foreground.stream;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      FirebaseMessaging.onMessage.listen(_foreground.add);
      _available = true;
    } catch (e) {
      debugPrint('FCM unavailable (no Firebase config?): $e');
    }
  }

  static Future<String?> token() async =>
      _available ? FirebaseMessaging.instance.getToken() : null;

  static Future<void> subscribe(String topic) async {
    if (_available) await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> unsubscribe(String topic) async {
    if (_available) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
  }
}
