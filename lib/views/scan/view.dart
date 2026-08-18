// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:schoolapp/core/core.dart';
// import 'package:schoolapp/views/views.dart' hide AppColor;
// import 'package:mobile_scanner/mobile_scanner.dart';

// class ScanView extends GetView<ScanController> {
//   const ScanView({super.key});

//   final double cutOutSize = 300;
//   @override
//   Widget build(BuildContext context) {
//     Get.put(ScanController());
//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         body: Stack(
//           children: [
//             MobileScanner(
//               controller: controller.mobileScannerCtl,
//               onDetect: (capture) {
//                 final barcode = capture.barcodes.first;
//                 final code = barcode.rawValue;

//                 if (code != null) {
//                   controller.scanCard(code); // ✅ now works
//                 }
//               },
//               scanWindow: Rect.fromCenter(
//                 center: Offset(Get.width / 2, Get.height / 2),
//                 width: cutOutSize,
//                 height: cutOutSize,
//               ),
//             ),

//             // Overlay
//             Container(
//               decoration: ShapeDecoration(
//                 shape: OverlayShape(
//                   borderRadius: 10,
//                   borderColor: AppColor.white,
//                   borderLength: 40,
//                   borderWidth: 10,
//                   cutOutBottomOffset: 0,
//                   cutOutWidth: null,
//                   cutOutHeight: null,
//                   cutOutSize: cutOutSize,
//                   overlayColor: const Color.fromRGBO(0, 0, 0, 80),
//                 ),
//               ),
//             ),

//             TitleWidget(cutOutSize: cutOutSize),

//             MessageWidget(cutOutSize: cutOutSize),
//           ],
//         ),
//       ),
//     );
//   }
// }
