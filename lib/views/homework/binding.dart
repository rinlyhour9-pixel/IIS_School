import 'package:get/get.dart';
import 'package:schoolapp/views/homework/controller.dart';

class HomeworkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeworkController>(() => HomeworkController());
  }
}
