import 'package:schoolapp/views/all_requested_leave/controller.dart';
import 'package:get/get.dart';

class AllRequestLeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllRequestleaveControlller>(() => AllRequestleaveControlller());
  }
}
