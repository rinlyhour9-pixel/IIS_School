import 'package:get/get.dart';
import 'package:schoolapp/views/student_document/controller.dart';

class StudentDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentDocumentController>(() => StudentDocumentController());
  }
}
