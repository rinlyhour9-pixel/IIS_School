import 'package:get/get.dart';
import 'package:schoolapp/views/student_attendance/controller.dart';

class StudentAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentAttendanceController>(
      () => StudentAttendanceController(),
    );
  }
}
