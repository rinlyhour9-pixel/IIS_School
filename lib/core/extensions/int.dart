import 'package:flutter/material.dart';
import 'package:schoolapp/core/constants/dimensions.dart';

extension IntX on int {
  Duration get minute => Duration(minutes: this);
  Duration get second => Duration(seconds: this);
  Duration get milliSecond => Duration(milliseconds: this);
  Duration get microseconds => Duration(microseconds: this);

  double get dynamicWidth => AppDimensions.width(this);
  double get dynamicHeight => AppDimensions.height(this);
  double get dynamicSize => AppDimensions.size(this);

  Widget get width => SizedBox(width: dynamicWidth);
  Widget get height => SizedBox(height: dynamicHeight);

  BorderRadius get radiusAll => BorderRadius.circular(AppDimensions.radius(this));

  EdgeInsets get padAll => AppDimensions.all(this);
  EdgeInsets get padHorizontal => AppDimensions.horizontal(this);
  EdgeInsets get padVertical => AppDimensions.vertical(this);
  EdgeInsets get padLeft => AppDimensions.only(left: this);
  EdgeInsets get padRight => AppDimensions.only(right: this);
  EdgeInsets get padBottom => AppDimensions.only(bottom: this);
  EdgeInsets get padTop => AppDimensions.only(top: this);
}
