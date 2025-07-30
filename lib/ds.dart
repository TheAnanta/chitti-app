import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';

void disableScreenshot(context) async {
  if (kIsWeb) {
    return;
  }
  final _noScreenshot = NoScreenshot.instance;
  bool result = await _noScreenshot.screenshotOff();

  _noScreenshot.screenshotStream.listen((value) {
    if (value.wasScreenshotTaken) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return MaterialApp(
            home: Scaffold(
              body: BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return SizedBox(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Screenshot Detected",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Please do not take screenshots while using this app.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }
  });
  await _noScreenshot.startScreenshotListening();
  debugPrint('Screenshot Off: $result');
}
