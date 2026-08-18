import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class DashbordBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DashboardController>()) {
      Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    }
  }
}
