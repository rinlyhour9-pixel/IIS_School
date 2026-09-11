import 'package:get/get.dart';
import 'package:schoolapp/views/assessment_management/controller.dart';

class AssessmentManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssessmentManagementController>(
      () => AssessmentManagementController(),
    );
  }
}
