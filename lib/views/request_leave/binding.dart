import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class RequestLeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestLeaveController>(() => RequestLeaveController());
  }
}
