import 'package:get/get.dart';
import 'controller.dart';

class DetailedAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailedAttendanceController>(
      () => DetailedAttendanceController(),
    );
  }
}
