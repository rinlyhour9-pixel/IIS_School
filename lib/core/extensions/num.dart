import 'package:flutter/widgets.dart';
import 'package:schoolapp/core/constants/dimensions.dart';
import 'package:schoolapp/core/constants/ui_constants.dart';

extension NumX on num {
  String get usdConvertor {
    return '\$${toStringAsFixed(2)}';
  }

  double get w => UIConstants.w(this);

  double get h => UIConstants.h(this);

  double get sp => UIConstants.sp(this);

  double get r => UIConstants.r(this);

  double get gap => UIConstants.gap(this);

  double get size => AppDimensions.size(this);

  EdgeInsets get dPadAll => UIConstants.padAll(this);
  EdgeInsets get dPadH => UIConstants.padH(this);
  EdgeInsets get dPadV => UIConstants.padV(this);

  EdgeInsets get dPadLeft => AppDimensions.only(left: this);
  EdgeInsets get dPadTop => AppDimensions.only(top: this);
  EdgeInsets get dPadRight => AppDimensions.only(right: this);
  EdgeInsets get dPadBottom => AppDimensions.only(bottom: this);

  Widget get dWidth => SizedBox(width: w);
  Widget get dHeight => SizedBox(height: h);
}
