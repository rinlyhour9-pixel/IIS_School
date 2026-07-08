import 'package:get/get.dart';
import 'package:schoolapp/views/record_attendance/controller.dart';

class RecordAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordAttendanceController>(() => RecordAttendanceController());
  }
}
