import 'package:flutter/material.dart';

enum WidthSizeClass { COMPACT, LARGE }

class WindowSizeClass {
  static late double width;

  void init(BuildContext context, BoxConstraints constraints) {
    width = constraints.maxWidth;
  }
}

getSizeClass() {
  return WindowSizeClass.width < 640
      ? WidthSizeClass.COMPACT
      : WidthSizeClass.LARGE;
}
