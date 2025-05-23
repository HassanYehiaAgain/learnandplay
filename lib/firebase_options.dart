// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB5elV5qeEUXbJRqGSJAZ6znMUDDwyBDWc',
    appId: '1:635834405606:web:1a9082ff011ef3e2966127',
    messagingSenderId: '635834405606',
    projectId: 'learn-play-87448',
    authDomain: 'learn-play-87448.firebaseapp.com',
    storageBucket: 'learn-play-87448.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUc0a3ErhA-d6wVc8UnZt02yTY0A5vQSI',
    appId: '1:635834405606:android:6d867e8ecaa36ef0966127',
    messagingSenderId: '635834405606',
    projectId: 'learn-play-87448',
    storageBucket: 'learn-play-87448.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCO5HxB5TdePS_exjTqmqPre9EuV5tioQU',
    appId: '1:635834405606:ios:1957bd6ea93444bf966127',
    messagingSenderId: '635834405606',
    projectId: 'learn-play-87448',
    storageBucket: 'learn-play-87448.firebasestorage.app',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.example.learnPlay',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCO5HxB5TdePS_exjTqmqPre9EuV5tioQU',
    appId: '1:635834405606:ios:1957bd6ea93444bf966127',
    messagingSenderId: '635834405606',
    projectId: 'learn-play-87448',
    storageBucket: 'learn-play-87448.firebasestorage.app',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.example.learnPlay',
  );
}
