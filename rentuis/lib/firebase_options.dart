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
    apiKey: 'AIzaSyDxlTWzo2Ds1O7GrTfqdP4AdwvY8T1z7fo',
    appId: '1:644496866992:web:b33496a6304a59e7774575',
    messagingSenderId: '644496866992',
    projectId: 'rentuisdatabase',
    authDomain: 'rentuisdatabase.firebaseapp.com',
    storageBucket: 'rentuisdatabase.appspot.com',
    measurementId: 'G-NQH36QWS65',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkkqcjgCgFobqKq2bt6PM-ziy620Jov2M',
    appId: '1:644496866992:android:ea142e637fa6b02b774575',
    messagingSenderId: '644496866992',
    projectId: 'rentuisdatabase',
    storageBucket: 'rentuisdatabase.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBeieDoKydU1K47LFQP6yaXKzG5s6p5yBk',
    appId: '1:644496866992:ios:972daed4eb1755b0774575',
    messagingSenderId: '644496866992',
    projectId: 'rentuisdatabase',
    storageBucket: 'rentuisdatabase.appspot.com',
    iosClientId: '644496866992-7qdqj3g2ndbpbtq2c5iukpi5fulqnett.apps.googleusercontent.com',
    iosBundleId: 'com.example.rentuis',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBeieDoKydU1K47LFQP6yaXKzG5s6p5yBk',
    appId: '1:644496866992:ios:18dbee4ec2ac348e774575',
    messagingSenderId: '644496866992',
    projectId: 'rentuisdatabase',
    storageBucket: 'rentuisdatabase.appspot.com',
    iosClientId: '644496866992-s20khloiav86o8n86utgt9kq8rql5b47.apps.googleusercontent.com',
    iosBundleId: 'com.example.rentuis.RunnerTests',
  );
}
