import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
