import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        text ?? LocaleKeys.noData.tr,
        style: AppTextStyle.mediumPrimaryBold,
      ),
    );
  }
}
