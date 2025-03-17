import 'package:flutter/material.dart';

enum WidthSizeClass { compact, large }

class WindowSizeClass {
  static late double width;

  void init(BuildContext context, BoxConstraints constraints) {
    width = constraints.maxWidth;
  }
}

getSizeClass() {
  return WindowSizeClass.width < 640
      ? WidthSizeClass.compact
      : WidthSizeClass.large;
}
