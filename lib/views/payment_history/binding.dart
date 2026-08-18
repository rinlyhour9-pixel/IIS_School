import 'package:get/get.dart';
import 'package:schoolapp/views/payment_history/controller.dart';

class PaymentHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentHistoryController>(() => PaymentHistoryController());
  }
}
