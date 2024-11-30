import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

/// A class to manage FirebaseOptions dynamically.
///
/// Initialize the `DefaultFirebaseOptions` by calling `initialize` in `main.dart`.
///
///
///
///
/// This file was added automatically after running flutterfire. It has been modified to
/// protect the API keys from being exposed.
///
/// IMPORTANT! This app must be run with the .env file in the /client folder for proper
/// connectivity. If you do not have the .env file, please contact Dennis Martin, James Mata
/// or Jared Henley.
///
///
class DefaultFirebaseOptions {
  static late FirebaseOptions web;
  static late FirebaseOptions android;
  static late FirebaseOptions ios;
  static late FirebaseOptions macos;
  static late FirebaseOptions windows;

  /// This method initializes FirebaseOptions with environment values.
  static void initialize({
    required String webApiKey,
    required String androidApiKey,
    required String iosApiKey,
    required String macosApiKey,
    required String windowsApiKey,
  }) {
    web = FirebaseOptions(
      apiKey: webApiKey,
      appId: '1:759254693643:web:8320bb127c2a36b75e540e',
      messagingSenderId: '759254693643',
      projectId: 'c365cloudmessaging',
      authDomain: 'c365cloudmessaging.firebaseapp.com',
      storageBucket: 'c365cloudmessaging.firebasestorage.app',
    );

    android = FirebaseOptions(
      apiKey: androidApiKey,
      appId: '1:759254693643:android:262e97649e4d39895e540e',
      messagingSenderId: '759254693643',
      projectId: 'c365cloudmessaging',
      storageBucket: 'c365cloudmessaging.firebasestorage.app',
    );

    ios = FirebaseOptions(
      apiKey: iosApiKey,
      appId: '1:759254693643:ios:c9f35d8577e22a675e540e',
      messagingSenderId: '759254693643',
      projectId: 'c365cloudmessaging',
      storageBucket: 'c365cloudmessaging.firebasestorage.app',
      iosBundleId: 'com.example.budget365',
    );

    macos = FirebaseOptions(
      apiKey: macosApiKey,
      appId: '1:759254693643:ios:c9f35d8577e22a675e540e',
      messagingSenderId: '759254693643',
      projectId: 'c365cloudmessaging',
      storageBucket: 'c365cloudmessaging.firebasestorage.app',
      iosBundleId: 'com.example.budget365',
    );

    windows = FirebaseOptions(
      apiKey: windowsApiKey,
      appId: '1:759254693643:web:eee91174de3ad3c65e540e',
      messagingSenderId: '759254693643',
      projectId: 'c365cloudmessaging',
      authDomain: 'c365cloudmessaging.firebaseapp.com',
      storageBucket: 'c365cloudmessaging.firebasestorage.app',
    );
  }

  ///Return FirebaseOptions based on the current platform.
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'please run the FlutterFire CLI again.',
        );
      default:
        return web;
    }
  }
}
