import 'package:get/get.dart';
import 'package:schoolapp/views/views.dart';

class StandingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StandingsController>(() => StandingsController());
  }
}
