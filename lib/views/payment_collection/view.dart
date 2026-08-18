import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';
import 'package:schoolapp/views/start/widgets/customize_app_bar.dart';
import 'package:schoolapp/views/views.dart';

class PaymentCollectionView extends GetView<PaymentCollectionController> {
  const PaymentCollectionView({super.key});

  void onSearch() async {
    if (!controller.formKey.currentState!.validate()) {
      return;
    }
    await controller.fetchTracking();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomizeAppBar(
                      title: 'ការបង់ថ្លៃសិក្សា',
                      subTitle:
                          'សូមពិនិត្យការបង់ថ្លៃសិក្សាកូនៗ​ របស់លោកអ្នកខាងក្រោមនេះ',
                      teacherSubTitle:
                          LocaleKeys.paymentCollectionTeacherSubTitle.tr,
                    ),
                  ],
                ),
              ),
            ),
          ),
          UIConstants.spacingSmall.height,
          const CustomIndicator(progress: 1 / 4),
          Expanded(child: Container(child: PaymentCardWidget())),
          UIConstants.spacingHigh.height,
        ],
      ),
    );
  }
}
