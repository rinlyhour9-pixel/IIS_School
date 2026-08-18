import 'package:flutter/material.dart';
import 'package:schoolapp/core/constants/asset_path.dart';

/// Display only: the social icons are not tappable and open nothing.
class SocialButtonCustom extends StatelessWidget {
  final String buttonText;
  final String imagePath;

  const SocialButtonCustom({
    super.key,
    required this.buttonText,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      padding: const EdgeInsets.all(0),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 2),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class SocialButtonCustomWidget extends StatelessWidget {
  const SocialButtonCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButtonCustom(buttonText: '', imagePath: AssetPath.fb.path),
            const SizedBox(width: 6),
            SocialButtonCustom(
              buttonText: '',
              imagePath: AssetPath.twitter.path,
            ),
            const SizedBox(width: 6),
            SocialButtonCustom(
              buttonText: '',
              imagePath: AssetPath.linked.path,
            ),
          ],
        ),
      ],
    );
  }
}
