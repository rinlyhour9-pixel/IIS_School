import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class PaymentCollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentCollectionController>(
      () => PaymentCollectionController(),
    );
  }
}
