import 'package:flutter/material.dart';

extension MediaQueryExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the screen height
  double get screenHeight => MediaQuery.of(this).size.height;
}
