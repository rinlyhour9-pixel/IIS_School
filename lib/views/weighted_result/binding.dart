import 'package:get/get.dart';
import 'package:schoolapp/views/weighted_result/controller.dart';

class WeightedResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeightedResultController>(() => WeightedResultController());
  }
}
