import 'package:flutter/material.dart';

class KiiteThreshold {
  static double get mobile => 540;
  static double get tablet => 960;
  static double get maxWidth => 1280;

  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width <= mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return mobile < width && width <= tablet;
  }

  static bool isPC(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return tablet < width;
  }

  static bool isFullWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return maxWidth < width;
  }
}
