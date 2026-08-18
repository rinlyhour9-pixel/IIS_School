import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/language/language.dart';

class ItemView extends StatelessWidget {
  const ItemView({super.key, this.isCambodia = true});

  final bool isCambodia;

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();

    return InkWell(
      onTap: () => controller.selectLanguage(isCambodia),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: UIConstants.radius.radiusAll,
          border: Border.all(width: 1, color: AppColor.lightGrey),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: 16.padAll,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                isCambodia
                    ? AssetPath.cambodiaFlag.path
                    : AssetPath.englishFlag.path,
                fit: BoxFit.cover,
                scale: 20,
              ),
              8.width,
              Text(
                isCambodia ? 'ភាសាខ្មែរ' : 'English',
                style: AppTextStyle.midPrimarySemiBold,
              ),
              const Spacer(),
              Obx(
                () => Radio<bool>(
                  value: isCambodia ? true : false,
                  groupValue: controller.isCambodia.value,
                  onChanged: (value) {
                    controller.selectLanguage(value ?? isCambodia);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
