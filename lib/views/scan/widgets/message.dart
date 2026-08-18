import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';

class MessageWidget extends StatelessWidget {
  final double cutOutSize;
  const MessageWidget({super.key, required this.cutOutSize});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: cutOutSize + 200),
        child: Text(
          'Place a barcode inside the viewfinder\nrectangle to scan it.',
          textAlign: TextAlign.center,
          style: AppTextStyle.normalWhiteRegular.copyWith(height: 1.7),
        ),
      ),
    );
  }
}
