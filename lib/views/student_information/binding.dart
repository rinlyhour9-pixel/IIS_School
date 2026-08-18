import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class StudentInformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentInformationController>(
      () => StudentInformationController(),
    );
  }
}
