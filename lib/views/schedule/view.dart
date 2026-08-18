import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/start/widgets/customize_app_bar.dart';
import 'package:schoolapp/views/views.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.scheduleTitle.tr,
              subTitle: LocaleKeys.scheduleSubTitle.tr,
              teacherSubTitle: LocaleKeys.scheduleTeacherSubTitle.tr,
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(),
              child: const ScheduleCardWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
