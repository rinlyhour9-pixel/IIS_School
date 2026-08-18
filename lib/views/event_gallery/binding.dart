import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class ActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivityController>(() => ActivityController());
  }
}
