import 'package:get/get.dart';
import 'package:schoolapp/views/score_verification/controller.dart';

class ScoreVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScoreVerificationController>(
      () => ScoreVerificationController(),
    );
  }
}
