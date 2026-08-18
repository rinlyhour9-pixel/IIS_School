import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key, required this.cutOutSize});

  final double cutOutSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(bottom: cutOutSize + 200),
        child: const Text('Scan QR Code', style: AppTextStyle.hugeWhiteBold),
      ),
    );
  }
}
