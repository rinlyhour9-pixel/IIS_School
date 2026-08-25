import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/score_entry/controller.dart';
import 'package:schoolapp/views/score_entry/widgets/card.dart';
import '../start/widgets/customize_app_bar.dart';

class ScoreEntryView extends GetView<ScoreEntryController> {
  const ScoreEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.scoreEntryTitle.tr,
              subTitle: LocaleKeys.scoreEntrySubTitle.tr,
              teacherSubTitle: LocaleKeys.scoreEntryTeacherSubTitle.tr,
            ),
          ),
          UIConstants.spacingSmall.height,
          // No RefreshIndicator here (unlike record_attendance): pull-to-refresh
          // would silently destroy scores typed but not yet saved.
          const Expanded(
            child: SingleChildScrollView(child: ScoreEntryCardWidget()),
          ),
        ],
      ),
    );
  }
}
