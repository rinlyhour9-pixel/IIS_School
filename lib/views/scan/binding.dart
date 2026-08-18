import 'package:schoolapp/views/scan/scan_log_controller.dart';
import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class ScanBinding extends Bindings {
  @override
  void dependencies() {
    //Get.lazyPut<ScanController>(() => ScanController());
    Get.lazyPut<CardScanController>(() => CardScanController());
  }
}
