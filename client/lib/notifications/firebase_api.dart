import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

//class connects the Budget-365 app with the Firebase server, enabling cloud messaging
class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging
        .getToken(); //I'm not going to print this value anymore, as the fCM token doesn't change

    //currently, messages are limited to background
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  //changing print statements so that they only occur during debug sessions
  if (kDebugMode) {
    print('${message.notification?.title}');
  }
  if (kDebugMode) {
    print('${message.notification?.body}');
  }
  if (kDebugMode) {
    print('${message.data}');
  }
}
