import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/term_condition/controller.dart';

class TermConditionView extends StatelessWidget {
  const TermConditionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TermConditionController());

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.termAndCondition.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(controller.error.value, textAlign: TextAlign.center),
          );
        }

        final model = controller.data.value;
        if (model == null || model.content.isEmpty) {
          return const Center(
            child: Text(
              'Terms & conditions are unavailable right now.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: HtmlWidget(model.content),
        );
      }),
    );
  }
}
