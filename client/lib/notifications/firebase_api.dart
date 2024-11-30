import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('${message.notification?.title}');
  print('${message.notification?.body}');
  print('${message.data}');
}

//class connects the Budget-365 app with the Firebase server, enabling cloud messaging
class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();

    //prints token for message testing
    print('Token: $fCMToken');

    //currently, messages are limited to background
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
