import 'package:schoolapp/views/all_requested_leave/widget/all_requested_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/start/widgets/customize_app_bar.dart';
import 'package:schoolapp/views/views.dart';

class AllRequestedLeaveView extends GetView<RequestLeaveController> {
  const AllRequestedLeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomizeAppBar(
              title: LocaleKeys.requestLeaveTitle.tr,
              subTitle: '',
              teacherSubTitle: LocaleKeys.allRequestedLeaveTeacherSubTitle.tr,
            ),
            const Expanded(child: AllRequestedCard()),
          ],
        ),
      ),
    );
  }
}
