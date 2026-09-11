import 'package:get/get.dart';
import 'package:schoolapp/views/view_score/controller.dart';

class ViewScoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewScoreController>(() => ViewScoreController());
  }
}
