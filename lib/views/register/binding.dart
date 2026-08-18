import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
