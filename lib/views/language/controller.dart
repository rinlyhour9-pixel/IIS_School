import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';

class LanguageController extends GetxController {
  final RxBool isCambodia = true.obs;

  /// True while a switch is in flight. `ItemView` disables both tiles during
  /// this window so a second tap can't race past the still-completing app
  /// reassemble that `AppConfig.updateLanguage` awaits.
  final RxBool isSwitching = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (AppConfig.shared.language == Language.en.key) {
      isCambodia.value = false;
    }
  }

  Future<void> selectLanguage(bool useCambodia) async {
    if (isCambodia.value == useCambodia || isSwitching.value) {
      return;
    }

    isSwitching.value = true;
    try {
      isCambodia.value = useCambodia;
      await AppConfig.shared.updateLanguage(
        useCambodia ? Language.kh.key : Language.en.key,
      );
    } finally {
      isSwitching.value = false;
    }
  }
}
