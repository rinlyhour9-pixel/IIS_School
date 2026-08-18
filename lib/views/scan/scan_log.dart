
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/scan/scan_log_controller.dart';
import 'package:schoolapp/views/scan/widgets/overlay.dart';

class CardScanView extends StatefulWidget {
  const CardScanView({super.key});

  @override
  State<CardScanView> createState() => _CardScanViewState();
}

class _CardScanViewState extends State<CardScanView> {
  late final CardScanController controller;

  @override
  void initState() {
    super.initState();
    controller =
        Get.isRegistered<CardScanController>()
            ? Get.find<CardScanController>()
            : Get.put(CardScanController());
    controller.isScanning.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final scannerBottomOffset =
              MediaQuery.of(context).padding.bottom + 80;

          return Stack(
            children: [
              MobileScanner(
                controller: controller.mobileScannerCtl,
                onDetect: (capture) {
                  if (!controller.isScanning.value ||
                      controller.isLoading.value) {
                    return;
                  }

                  for (final barcode in capture.barcodes) {
                    final raw = barcode.rawValue;

                    if (raw != null && raw.isNotEmpty) {
                      controller.isScanning.value = false;
                      HapticFeedback.mediumImpact();
                      controller.handleDetectedQr(
                        raw: raw,
                        lat: 11.5621,
                        lng: 104.9243,
                      );
                      break;
                    }
                  }
                },
                scanWindow: Rect.fromCenter(
                  center: Offset(size.width / 2, size.height / 2),
                  width: 250,
                  height: 250,
                ),
              ),

              _buildScannerOverlay(controller, scannerBottomOffset),

              Obx(
                () =>
                    controller.isLoading.value
                        ? Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildScannerOverlay(
    CardScanController controller,
    double scannerBottomOffset,
  ) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: ShapeDecoration(
              shape: OverlayShape(
                borderColor: Colors.white,
                borderWidth: 4,
                borderRadius: 14,
                borderLength: 34,
                cutOutSize: 0.0,
                cutOutWidth: 250,
                cutOutHeight: 250,
                cutOutBottomOffset: 0,
                overlayColor: Colors.black.withOpacity(0.85),
              ),
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: 24,
          right: 24,
          child: Text(
            LocaleKeys.scanQrCodeToLogAttendance.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Positioned(
          bottom: scannerBottomOffset,
          left: 0,
          right: 0,
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: controller.switchCamera,
                  iconSize: 34,
                  color: Colors.white,
                  icon: Icon(
                    controller.cameraFacing.value == CameraFacing.front
                        ? Icons.cameraswitch
                        : Icons.cameraswitch_outlined,
                  ),
                ),
                const SizedBox(width: 42),
                IconButton(
                  onPressed: controller.switchFlash,
                  iconSize: 34,
                  color: Colors.white,
                  icon: Icon(
                    controller.isTorchOn.value
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:schoolapp/views/scan/scan_log_controller.dart';

// class CardScanView extends StatefulWidget {
//   const CardScanView({super.key});

//   @override
//   State<CardScanView> createState() => _CardScanViewState();
// }

// class _CardScanViewState extends State<CardScanView> {
//   late final CardScanController controller;
//   bool _cameraOpen = false;
//   String? _lastCode;
//   DateTime? _lastScanAt;

//   final List<_PackagingItem> _items = <_PackagingItem>[
//     const _PackagingItem(
//       index: 1,
//       product: 'ទឹកក្រូច',
//       scanCount: 2,
//       quantity: 2,
//       unit: '250G',
//     ),
//     const _PackagingItem(
//       index: 2,
//       product: 'ទឹកត្រី',
//       scanCount: null,
//       quantity: 1,
//       unit: '-',
//     ),
//   ];

//   int get _verifiedCount => _items.where((item) => item.isVerified).length;

//   @override
//   void initState() {
//     super.initState();
//     controller =
//         Get.isRegistered<CardScanController>()
//             ? Get.find<CardScanController>()
//             : Get.put(CardScanController());
//     controller.isScanning.value = false;
//   }

//   @override
//   void dispose() {
//     controller.isScanning.value = false;
//     controller.mobileScannerCtl.stop();
//     super.dispose();
//   }

//   Future<void> _openCamera() async {
//     setState(() => _cameraOpen = true);
//     controller.isScanning.value = true;
//     await controller.mobileScannerCtl.start();
//   }

//   Future<void> _closeCamera() async {
//     controller.isScanning.value = false;
//     await controller.mobileScannerCtl.stop();
//     if (mounted) {
//       setState(() => _cameraOpen = false);
//     }
//   }

//   void _handleDetectedCode(String raw) {
//     final code = raw.trim();
//     if (code.isEmpty) {
//       return;
//     }

//     final now = DateTime.now();
//     if (_lastCode == code &&
//         _lastScanAt != null &&
//         now.difference(_lastScanAt!) < const Duration(seconds: 2)) {
//       return;
//     }
//     _lastCode = code;
//     _lastScanAt = now;

//     final targetIndex = _items.indexWhere((item) => !item.isVerified);
//     if (targetIndex == -1) {
//       HapticFeedback.lightImpact();
//       return;
//     }

//     HapticFeedback.mediumImpact();
//     setState(() {
//       final item = _items[targetIndex];
//       final nextCount = (item.scanCount ?? 0) + 1;
//       _items[targetIndex] = item.copyWith(scanCount: nextCount);
//     });
//   }

//   void _submitItems() {
//     final pending = _items.where((item) => !item.isVerified).length;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           pending == 0
//               ? 'All items are verified.'
//               : '$pending item(s) still need scanning.',
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F7FB),
//       body: Column(
//         children: [
//           _PackagingHeader(verified: _verifiedCount, total: _items.length),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
//               children: [
//                 _CameraPanel(
//                   cameraOpen: _cameraOpen,
//                   controller: controller,
//                   onOpenCamera: _openCamera,
//                   onCloseCamera: _closeCamera,
//                   onDetected: _handleDetectedCode,
//                 ),
//                 const SizedBox(height: 18),
//                 const _InvoiceSummaryCard(),
//                 const SizedBox(height: 22),
//                 _PackagingItemsTable(items: _items),
//                 const SizedBox(height: 30),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: SizedBox(
//                     width: 224,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: _submitItems,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2499E8),
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: const Text(
//                         'Submit All Items',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PackagingHeader extends StatelessWidget {
//   const _PackagingHeader({required this.verified, required this.total});

//   final int verified;
//   final int total;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF0054BF), Color(0xFF064AAD)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: SizedBox(
//           height: 64,
//           child: Row(
//             children: [
//               IconButton(
//                 onPressed: () => Navigator.of(context).maybePop(),
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: Colors.white,
//                   size: 22,
//                 ),
//               ),
//               const Expanded(
//                 child: Text(
//                   'Packaging',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.only(right: 16),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 9,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(18),
//                   border: Border.all(
//                     color: Colors.white.withValues(alpha: 0.16),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.verified_user_outlined,
//                       color: Color(0xFFB8DCFF),
//                       size: 19,
//                     ),
//                     const SizedBox(width: 7),
//                     Text(
//                       '$verified / $total verified',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CameraPanel extends StatelessWidget {
//   const _CameraPanel({
//     required this.cameraOpen,
//     required this.controller,
//     required this.onOpenCamera,
//     required this.onCloseCamera,
//     required this.onDetected,
//   });

//   final bool cameraOpen;
//   final CardScanController controller;
//   final VoidCallback onOpenCamera;
//   final VoidCallback onCloseCamera;
//   final ValueChanged<String> onDetected;

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 0.86,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(2),
//         child: ColoredBox(
//           color: const Color(0xFFD9D9D9),
//           child:
//               cameraOpen
//                   ? Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       MobileScanner(
//                         controller: controller.mobileScannerCtl,
//                         onDetect: (capture) {
//                           if (!controller.isScanning.value) {
//                             return;
//                           }
//                           for (final barcode in capture.barcodes) {
//                             final raw = barcode.rawValue;
//                             if (raw != null && raw.trim().isNotEmpty) {
//                               onDetected(raw);
//                               break;
//                             }
//                           }
//                         },
//                       ),
//                       const _ScannerFrame(),
//                       Positioned(
//                         top: 16,
//                         right: 16,
//                         child: _RoundIconButton(
//                           icon: Icons.close_rounded,
//                           onTap: onCloseCamera,
//                         ),
//                       ),
//                       const Positioned(
//                         left: 36,
//                         right: 36,
//                         bottom: 18,
//                         child: _ScannerHint(),
//                       ),
//                     ],
//                   )
//                   : Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 130,
//                           height: 130,
//                           decoration: const BoxDecoration(
//                             color: Color(0xFFCFCFCF),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.photo_camera_outlined,
//                             color: Colors.white,
//                             size: 58,
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: onOpenCamera,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF0659C9),
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 14,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'Open Camera',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//         ),
//       ),
//     );
//   }
// }

// class _ScannerFrame extends StatelessWidget {
//   const _ScannerFrame();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         width: 250,
//         height: 250,
//         child: CustomPaint(painter: _ScannerFramePainter()),
//       ),
//     );
//   }
// }

// class _ScannerFramePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = Colors.white
//           ..strokeWidth = 4
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round;
//     const length = 42.0;
//     const radius = 18.0;
//     final path =
//         Path()
//           ..moveTo(radius, 0)
//           ..lineTo(length, 0)
//           ..moveTo(0, radius)
//           ..lineTo(0, length)
//           ..moveTo(size.width - length, 0)
//           ..lineTo(size.width - radius, 0)
//           ..quadraticBezierTo(size.width, 0, size.width, radius)
//           ..lineTo(size.width, length)
//           ..moveTo(size.width, size.height - length)
//           ..lineTo(size.width, size.height - radius)
//           ..quadraticBezierTo(
//             size.width,
//             size.height,
//             size.width - radius,
//             size.height,
//           )
//           ..lineTo(size.width - length, size.height)
//           ..moveTo(length, size.height)
//           ..lineTo(radius, size.height)
//           ..quadraticBezierTo(0, size.height, 0, size.height - radius)
//           ..lineTo(0, size.height - length);
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _ScannerHint extends StatelessWidget {
//   const _ScannerHint();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 44,
//       decoration: BoxDecoration(
//         color: const Color(0xDD3C4E79),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFDA8B42), width: 1.3),
//       ),
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
//           SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               'Hold the barcode inside the frame',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RoundIconButton extends StatelessWidget {
//   const _RoundIconButton({required this.icon, required this.onTap});

//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       customBorder: const CircleBorder(),
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: const BoxDecoration(
//           color: Color(0xC9365380),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: Colors.white, size: 26),
//       ),
//     );
//   }
// }

// class _InvoiceSummaryCard extends StatelessWidget {
//   const _InvoiceSummaryCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0F4B5563),
//             blurRadius: 20,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
//       child: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Text(
//               'Invoice Summary',
//               style: TextStyle(
//                 color: Color(0xFF334155),
//                 fontSize: 17,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           _SummaryLabel(label: 'Client', value: 'Siv Meân'),
//           SizedBox(height: 18),
//           Row(
//             children: [
//               Expanded(
//                 child: _SummaryLabel(label: 'Code Number', value: 'B0065066'),
//               ),
//               SizedBox(width: 20),
//               Expanded(child: _SummaryLabel(label: 'Item', value: '2')),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SummaryLabel extends StatelessWidget {
//   const _SummaryLabel({required this.label, required this.value});

//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Color(0xFFB6BCC6),
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             color: Color(0xFF1F2937),
//             fontSize: 16,
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PackagingItemsTable extends StatelessWidget {
//   const _PackagingItemsTable({required this.items});

//   final List<_PackagingItem> items;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFD7DEE8)),
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
//       child: Column(
//         children: [
//           const _PackagingTableHeader(),
//           const SizedBox(height: 8),
//           for (final item in items) ...[
//             _PackagingTableRow(item: item),
//             if (item != items.last) const SizedBox(height: 8),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _PackagingTableHeader extends StatelessWidget {
//   const _PackagingTableHeader();

//   @override
//   Widget build(BuildContext context) {
//     return const Row(
//       children: [
//         SizedBox(width: 28, child: Text('#', style: _headerStyle)),
//         Expanded(flex: 3, child: Text('Product', style: _headerStyle)),
//         Expanded(
//           flex: 3,
//           child: Center(child: Text('Scan Count', style: _headerStyle)),
//         ),
//         Expanded(
//           flex: 2,
//           child: Center(child: Text('Qty', style: _headerStyle)),
//         ),
//         Expanded(
//           flex: 2,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text('Unit', style: _headerStyle),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PackagingTableRow extends StatelessWidget {
//   const _PackagingTableRow({required this.item});

//   final _PackagingItem item;

//   @override
//   Widget build(BuildContext context) {
//     final color =
//         item.isVerified ? const Color(0xFF6CB4E9) : const Color(0xFFF7C274);
//     final foreground =
//         item.isVerified ? const Color(0xFF061C2F) : const Color(0xFF111827);

//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 28,
//             child: Center(
//               child: Text('${item.index}', style: _rowStyle(foreground)),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               item.product,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: _rowStyle(foreground),
//             ),
//           ),
//           _VerticalDivider(item.isVerified),
//           Expanded(
//             flex: 3,
//             child: Center(
//               child: Text(item.scanText, style: _rowStyle(foreground)),
//             ),
//           ),
//           _VerticalDivider(item.isVerified),
//           Expanded(
//             flex: 2,
//             child: Center(
//               child: Text('${item.quantity}', style: _rowStyle(foreground)),
//             ),
//           ),
//           _VerticalDivider(item.isVerified),
//           Expanded(
//             flex: 2,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(item.unit, style: _rowStyle(foreground)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _VerticalDivider extends StatelessWidget {
//   const _VerticalDivider(this.strong);

//   final bool strong;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 1,
//       height: 34,
//       color: Colors.white.withValues(alpha: strong ? 0.55 : 0.35),
//     );
//   }
// }

// const TextStyle _headerStyle = TextStyle(
//   color: Colors.black,
//   fontSize: 16,
//   fontWeight: FontWeight.w800,
// );

// TextStyle _rowStyle(Color color) {
//   return TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700);
// }

// class _PackagingItem {
//   const _PackagingItem({
//     required this.index,
//     required this.product,
//     required this.scanCount,
//     required this.quantity,
//     required this.unit,
//   });

//   final int index;
//   final String product;
//   final int? scanCount;
//   final int quantity;
//   final String unit;

//   bool get isVerified => (scanCount ?? 0) >= quantity;
//   String get scanText => scanCount == null ? '-' : '$scanCount';

//   _PackagingItem copyWith({int? scanCount}) {
//     return _PackagingItem(
//       index: index,
//       product: product,
//       scanCount: scanCount ?? this.scanCount,
//       quantity: quantity,
//       unit: unit,
//     );
//   }
// }
