import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppDimensions {
  AppDimensions._();

  static const double designWidth = 375;
  static const double designHeight = 812;

  static BuildContext? get _context => Get.context;

  static Size get _screenSize {
    final context = _context;
    if (context != null) {
      return MediaQuery.sizeOf(context);
    }
    return const Size(designWidth, designHeight);
  }

  static double scaleWidth([BuildContext? context]) {
    final size = context != null ? MediaQuery.sizeOf(context) : _screenSize;
    return size.width / designWidth;
  }

  static double scaleHeight([BuildContext? context]) {
    final size = context != null ? MediaQuery.sizeOf(context) : _screenSize;
    return size.height / designHeight;
  }

  static double scaleSize([BuildContext? context]) {
    final value = (scaleWidth(context) + scaleHeight(context)) / 2;
    return value.clamp(0.85, 1.25);
  }

  static double width(num value, {BuildContext? context}) {
    return value * scaleWidth(context);
  }

  static double height(num value, {BuildContext? context}) {
    return value * scaleHeight(context);
  }

  static double size(num value, {BuildContext? context}) {
    return value * scaleSize(context);
  }

  static double font(num value, {BuildContext? context}) {
    return size(value, context: context);
  }

  static double radius(num value, {BuildContext? context}) {
    return size(value, context: context);
  }

  static double spacing(num value, {BuildContext? context}) {
    return width(value, context: context);
  }

  static EdgeInsets all(num value, {BuildContext? context}) {
    return EdgeInsets.all(spacing(value, context: context));
  }

  static EdgeInsets horizontal(num value, {BuildContext? context}) {
    return EdgeInsets.symmetric(horizontal: spacing(value, context: context));
  }

  static EdgeInsets vertical(num value, {BuildContext? context}) {
    return EdgeInsets.symmetric(vertical: spacing(value, context: context));
  }

  static EdgeInsets only({
    num left = 0,
    num top = 0,
    num right = 0,
    num bottom = 0,
    BuildContext? context,
  }) {
    return EdgeInsets.only(
      left: spacing(left, context: context),
      top: height(top, context: context),
      right: spacing(right, context: context),
      bottom: height(bottom, context: context),
    );
  }
}
