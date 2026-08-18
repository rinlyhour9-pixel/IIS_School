import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/routes.dart';

class SplashController extends GetxController {
  static const Duration _minSplashTime = Duration(milliseconds: 2000);
  static const Duration _maxSplashTime = Duration(milliseconds: 900);
  bool _didNavigate = false;

  @override
  void onReady() {
    super.onReady();
    fetchInit();
  }

  Future<void> fetchInit() async {
    final startedAt = DateTime.now();
    try {
      final rawToken =
          await SharedPreferencesManager.get(
            Credential.token.name,
          ).timeout(_maxSplashTime, onTimeout: () => '') ??
          '';
      if (_didNavigate || isClosed) {
        return;
      }

      _didNavigate = true;
      final token = rawToken.toString().trim();
      final hasValidToken =
          token.isNotEmpty &&
          token.toLowerCase() != 'null' &&
          token.toLowerCase() != 'undefined' &&
          token.toLowerCase() != 'false';

      final elapsed = DateTime.now().difference(startedAt);
      final wait = _minSplashTime - elapsed;
      if (wait > Duration.zero) {
        await Future.delayed(wait);
      }
      if (isClosed) {
        return;
      }

      if (!hasValidToken) {
        Get.offNamed(Routes.login);
        return;
      }
      Get.offNamed(Routes.start);
    } catch (_) {
      if (_didNavigate || isClosed) {
        return;
      }
      _didNavigate = true;
      Get.offNamed(Routes.login);
    }
  }
}
