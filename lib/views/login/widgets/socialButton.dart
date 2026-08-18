import 'package:flutter/material.dart';
import 'package:schoolapp/core/constants/asset_path.dart';

// Define a function to handle button taps
void handleFacebookLogin() {}

void handleGoogleLogin() {}

void handleTwitterLogin() {}

class SocialButton extends StatelessWidget {
  final String buttonText;
  final String imagePath;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.buttonText,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 30,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 30, height: 30, fit: BoxFit.fill),

            Text(
              buttonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialButtonsWidget extends StatelessWidget {
  const SocialButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(
              buttonText: '',
              imagePath: AssetPath.fb.path,
              onPressed: handleFacebookLogin,
            ),
            const SizedBox(width: 10),
            SocialButton(
              buttonText: '',
              imagePath: AssetPath.youtube.path,
              onPressed: handleGoogleLogin,
            ),
            const SizedBox(width: 12),
            SocialButton(
              buttonText: '',
              imagePath: AssetPath.twitter.path,
              onPressed: handleTwitterLogin,
            ),
          ],
        ),
      ],
    );
  }
}
