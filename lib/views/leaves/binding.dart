import 'package:get/get.dart';
import 'package:schoolapp/views/leaves/controller.dart';

class LeavesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeavesController>(() => LeavesController());
  }
}
