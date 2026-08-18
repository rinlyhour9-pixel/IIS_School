import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';
import 'package:schoolapp/views/attendance/controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceController>(() => AttendanceController());
  }
}
