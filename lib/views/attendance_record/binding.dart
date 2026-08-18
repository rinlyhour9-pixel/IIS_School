import 'package:schoolapp/views/attendance_record/controller.dart';
import 'package:get/get.dart';

class AttendanceRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceRecordController>(() => AttendanceRecordController());
  }
}
