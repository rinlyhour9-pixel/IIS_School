import 'package:get/get.dart';
import 'package:schoolapp/views/score_entry/controller.dart';

class ScoreEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScoreEntryController>(() => ScoreEntryController());
  }
}
