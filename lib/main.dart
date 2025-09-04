import 'dart:io';

import 'package:chitti/firebase_options.dart';
import 'package:chitti/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fvp/fvp.dart' as fvp;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // APNS for IOS
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  fvp.registerWith();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  HttpOverrides.global = new MyHttpOverrides();
  if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
    final notificationSettings = await FirebaseMessaging.instance
        .requestPermission(
          provisional: false,
          alert: true,
          badge: true,
          sound: true,
          announcement: true,
          criticalAlert: true,
        );
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print("APNS Token: $apnsToken");
    print(
      'User granted permission: ${notificationSettings.authorizationStatus}',
    );
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      // requested permission
      final notificationSettings = await FirebaseMessaging.instance
          .requestPermission(
            provisional: false,
            alert: true,
            badge: true,
            sound: true,
            announcement: true,
            criticalAlert: true,
          );
    }
    print(
      'Firebase Messaging Token: ${await FirebaseMessaging.instance.getToken()}',
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChittiMaterialApp();
  }
}

class ChittiCupertinoApp extends StatelessWidget {
  const ChittiCupertinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(),
      debugShowCheckedModeBanner: false,
      home: CupertinoTabView(
        builder: (context) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text("Chitti.")),
            child: Center(
              child: CupertinoButton.filled(
                child: Text("This is a cupertino app."),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChittiMaterialApp extends StatelessWidget {
  const ChittiMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chitti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0D47A1)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0D47A1),
          brightness: Brightness.dark,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
