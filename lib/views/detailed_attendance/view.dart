import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import '../start/widgets/customize_app_bar.dart';
import 'controller.dart';
import 'widgets/widgets.dart';

class DetailedAttendanceView extends GetView<DetailedAttendanceController> {
  const DetailedAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: 'Attendance Detail',
              subTitle: 'Review recorded attendance',
              teacherSubTitle: '',
            ),
          ),
          UIConstants.spacingSmall.height,
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(child: const DetailedAttendanceCardWidget()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
