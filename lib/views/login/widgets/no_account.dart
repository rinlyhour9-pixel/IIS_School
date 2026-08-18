import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/routes.dart';

class NoAccountWidget extends StatelessWidget {
  const NoAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            InkWell(
              child: Container(
                height: 24,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: LocaleKeys.forgotPassword.tr,
                        style: AppTextStyle.normalPrimaryRegular,
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => Get.toNamed(Routes.register),
            ),
            20.width,
            InkWell(
              child: Container(
                height: 24,
                alignment: Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: LocaleKeys.doNotHaveAnAccount.tr,
                        style: AppTextStyle.normalPrimaryRegular,
                      ),
                      TextSpan(
                        text: LocaleKeys.register.tr,
                        style: AppTextStyle.normalRedRegular,
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => Get.toNamed(Routes.register),
            ),
          ],
        ),
      ],
    );
  }
}
