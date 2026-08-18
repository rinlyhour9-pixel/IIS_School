import 'package:flutter/widgets.dart';
import 'package:schoolapp/core/constants/dimensions.dart';

class UIConstants {
  static const int spacing = 16;
  static const int spacingSmall = 12;
  static const int spacingMedium = 18;
  static const int spacingHigh = 50;
  static const int midSpacing = spacing ~/ 2;
  static const int radius = 8;
  static const double btnHeight = 50;
  static const double designWidth = AppDimensions.designWidth;
  static const double designHeight = AppDimensions.designHeight;

  // Dynamic width
  static double w(num value, {BuildContext? context}) {
    return AppDimensions.width(value, context: context);
  }

  // Dynamic height
  static double h(num value, {BuildContext? context}) {
    return AppDimensions.height(value, context: context);
  }

  // Dynamic font size
  static double sp(num value, {BuildContext? context}) {
    return AppDimensions.font(value, context: context);
  }

  // Dynamic radius
  static double r(num value, {BuildContext? context}) {
    return AppDimensions.radius(value, context: context);
  }

  // Dynamic uniform spacing (scaled by width)
  static double gap(num value, {BuildContext? context}) {
    return AppDimensions.spacing(value, context: context);
  }

  static EdgeInsets padAll(num value, {BuildContext? context}) {
    return AppDimensions.all(value, context: context);
  }

  static EdgeInsets padH(num value, {BuildContext? context}) {
    return AppDimensions.horizontal(value, context: context);
  }

  static EdgeInsets padV(num value, {BuildContext? context}) {
    return AppDimensions.vertical(value, context: context);
  }
}
