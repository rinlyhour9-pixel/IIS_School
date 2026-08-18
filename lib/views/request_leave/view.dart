import 'package:schoolapp/views/request_leave/widgets/student_card1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/core/constants/ui_constants.dart';
import 'package:schoolapp/core/extensions/int.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';
import 'package:schoolapp/views/start/widgets/customize_app_bar.dart';
import 'package:schoolapp/views/views.dart';

class RequestLeaveView extends GetView<RequestLeaveController> {
  const RequestLeaveView({super.key});

  void onSearch() async {
    if (!controller.formKey.currentState!.validate()) {
      return;
    }
    await controller.fetchTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomizeAppBar(
              title: LocaleKeys.requestLeaveTitle.tr,
              subTitle: LocaleKeys.requestLeaveSubTitle.tr,
              teacherSubTitle: LocaleKeys.requestLeaveTeacherSubTitle.tr,
            ),
            UIConstants.spacingSmall.height,
            CustomIndicator(progress: 1 / 4),
            Expanded(child: Container(child: StudentCard1Widget())),
          ],
        ),
      ),
    );
  }
}
