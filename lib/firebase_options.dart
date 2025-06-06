// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDBuTmrhW_He5kYoiR0GJhA-wEYQn185bA',
    appId: '1:513797872748:web:550d59b9e84a4430368c49',
    messagingSenderId: '513797872748',
    projectId: 'chitti-ananta',
    authDomain: 'chitti-ananta.firebaseapp.com',
    storageBucket: 'chitti-ananta.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDMp4BobtekUyUhayYHDRm-6pkNZp0M5IU',
    appId: '1:513797872748:android:163c2dc2c5eb61f0368c49',
    messagingSenderId: '513797872748',
    projectId: 'chitti-ananta',
    storageBucket: 'chitti-ananta.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2ApdpjaXZ_EQP-yFOXKLhAm0PaVg_9X4',
    appId: '1:513797872748:ios:9443903e441b8fbd368c49',
    messagingSenderId: '513797872748',
    projectId: 'chitti-ananta',
    storageBucket: 'chitti-ananta.firebasestorage.app',
    iosBundleId: 'dev.theananta.chitti',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA2ApdpjaXZ_EQP-yFOXKLhAm0PaVg_9X4',
    appId: '1:513797872748:ios:a4e7f08d35587e23368c49',
    messagingSenderId: '513797872748',
    projectId: 'chitti-ananta',
    storageBucket: 'chitti-ananta.firebasestorage.app',
    iosBundleId: 'dev.theananta.chitti.macos',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDBuTmrhW_He5kYoiR0GJhA-wEYQn185bA',
    appId: '1:513797872748:web:c43507196d1b710c368c49',
    messagingSenderId: '513797872748',
    projectId: 'chitti-ananta',
    authDomain: 'chitti-ananta.firebaseapp.com',
    storageBucket: 'chitti-ananta.firebasestorage.app',
  );

}