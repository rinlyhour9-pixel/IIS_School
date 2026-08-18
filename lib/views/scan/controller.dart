import 'dart:async';
import 'package:schoolapp/models/student/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController getProdCtl = TextEditingController();

  late MobileScannerController mobileScannerCtl;
  late StreamSubscription<Object?> subscription;
  final Rx<CameraFacing> cameraFacing = CameraFacing.back.obs;
  final RxBool isTorchOn = false.obs;
  var isLoading = false.obs;
  var student = Rxn<Student>();
  var message = ''.obs;
  var isSuccess = false.obs;
  @override
  void onInit() async {
    mobileScannerCtl = MobileScannerController();
    await cameraListen();
    super.onInit();
  }

  Future<void> cameraListen() async {
    subscription = mobileScannerCtl.barcodes.listen((
      BarcodeCapture capture,
    ) async {
      final List<Barcode> barcodes = capture.barcodes;

      for (final barcode in barcodes) {
        if ((barcode.rawValue ?? '').isEmpty) {
          ExceptionHandler.handleException('Cannot get result from the QRCode');
          return;
        }
        await onDetected(barcode.rawValue!);

        // Access only first time detect of QR code
        return;
      }
    });
  }

  @override
  void onClose() {
    mobileScannerCtl.dispose();
    subscription.cancel();
    getProdCtl.dispose();
    super.onClose();
  }

  Future<void> switchCamera() async {
    await mobileScannerCtl.switchCamera();
    cameraFacing.value =
        cameraFacing.value == CameraFacing.back
            ? CameraFacing.front
            : CameraFacing.back;
  }

  Future<void> switchFlash() async {
    mobileScannerCtl.toggleTorch();
  }

  void clear() {
    getProdCtl.text = '';
  }

  Future<void> onDetected(String value) async {
    try {
      await scanCard(value);
    } catch (e) {
      ExceptionHandler.handleException('Scan failed. Please try again.');
    }
  }

  Future<void> scanCard(String uid) async {
    try {
      mobileScannerCtl.stop();

      final response = await Get.find<ApiService>().post(
        EndPoints.studentScanCard,
        {"card_uid": uid},
        isShowLoading: true,
      );

      final data = response.data;

      final student = data['student'];
      final message = data['message'];
      final success = data['success'];

      DialogManager.showCustom(
        PrimaryDialog(
          title: success ? "Success" : "Warning",
          subTitle: "${student['firstname']} ${student['lastname']}\n$message",
          onPressed: () => Get.back(),
        ),
      ).then((_) {
        mobileScannerCtl.start();
      });
    } catch (e) {
      ExceptionHandler.handleException(
        e,
        onValue: (p0) {
          mobileScannerCtl.start();
        },
      );
    }
  }
}
