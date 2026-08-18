import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class SocialLoginWidget extends StatelessWidget {
  const SocialLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20.0),
        Container(
          alignment: Alignment.center,
          child: const Text(
            "ជ្រើសរើសភាសារបស់អ្នក",
            style: AppTextStyle.normalPrimaryRegular,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetPath.cambodiaFlag.path,
                fit: BoxFit.cover,
                width: 15,
                height: 15,
                scale: 20,
              ),
              8.width,
              const Text('ខ្មែរ', style: AppTextStyle.midPrimarySemiBold),
              8.width,
              const Text('|', style: AppTextStyle.midPrimarySemiBold),
              8.width,
              Image.asset(
                AssetPath.englishFlag.path,
                fit: BoxFit.cover,
                width: 15,
                height: 15,
                scale: 20,
              ),
              8.width,
              const Text('Eng', style: AppTextStyle.midPrimarySemiBold),
            ],
          ),
        ),
      ],
    );
  }
}
