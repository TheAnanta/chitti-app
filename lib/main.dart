import 'package:chitti/ds.dart';
import 'package:chitti/firebase_options.dart';
import 'package:chitti/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Pdfrx.webRuntimeType = PdfrxWebRuntimeType.pdfiumWasm;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const SplashScreen(),
    );
  }
}
