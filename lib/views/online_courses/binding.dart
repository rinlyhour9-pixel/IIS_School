import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class OnlineCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnlineCoursesController>(() => OnlineCoursesController());
  }
}
