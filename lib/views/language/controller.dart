import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';

class LanguageController extends GetxController {
  final RxBool isCambodia = true.obs;

  @override
  void onInit() async {
    if (AppConfig.shared.language == Language.en.key) {
      isCambodia.value = false;
    }
    super.onInit();
  }

  void selectLanguage(bool useCambodia) {
    if (isCambodia.value == useCambodia) {
      return;
    }

    isCambodia.value = useCambodia;
    AppConfig.shared.updateLanguage(
      useCambodia ? Language.kh.key : Language.en.key,
    );
  }
}
