import 'package:flutter/material.dart';

enum WidthSizeClass { compact, large }

class WindowSizeClass {
  static late double width;

  void init(BoxConstraints constraints) {
    width = constraints.maxWidth;
  }
}

WidthSizeClass getSizeClass() {
  return WindowSizeClass.width < 640
      ? WidthSizeClass.compact
      : WidthSizeClass.large;
}
