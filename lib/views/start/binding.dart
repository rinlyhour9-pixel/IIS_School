import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class StartBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StartController>()) {
      Get.lazyPut<StartController>(() => StartController(), fenix: true);
    }
    if (!Get.isRegistered<DashboardController>()) {
      Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    }
    if (!Get.isRegistered<PaymentHistoryController>()) {
      Get.lazyPut<PaymentHistoryController>(
        () => PaymentHistoryController(),
        fenix: true,
      );
    }
  }
}
