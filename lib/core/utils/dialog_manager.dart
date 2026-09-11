import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';

class DialogManager {
  DialogManager._();
  static DateTime? _lastSnackbarAt;
  static String _lastSnackbarMessage = '';

  static bool get _isGetReady =>
      Get.context != null ||
      Get.overlayContext != null ||
      Get.key.currentContext != null;

  static bool get _hasOpenOverlay =>
      _isGetReady && (Get.isDialogOpen ?? false || Get.isOverlaysOpen);

  static void _closeOpenOverlays({required bool closeOverlays}) {
    while (_hasOpenOverlay && Get.key.currentState?.canPop() == true) {
      Get.back(closeOverlays: closeOverlays);
    }
  }

  static Future<dynamic> showCustom(
    Widget content, {
    bool barrierDismissible = true,
  }) {
    if (!_isGetReady) {
      return Future.value();
    }

    _closeOpenOverlays(closeOverlays: false);

    return Get.dialog(
      content,
      barrierDismissible: barrierDismissible,
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  static Future<dynamic> showDialog({
    required String title,
    required String subTitle,
    Function()? onPressed,
    String? btnText,
  }) async {
    if (!_isGetReady) {
      return Future.value();
    }

    _closeOpenOverlays(closeOverlays: false);

    return Get.dialog(
      barrierDismissible: false,
      PrimaryDialog(
        title: title,
        subTitle: subTitle,
        onPressed: () {
          Get.back();
          onPressed?.call();
        },
      ),
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  static Future<dynamic> showConnectionDialog() async {
    if (!_isGetReady) {
      return Future.value();
    }

    _closeOpenOverlays(closeOverlays: true);

    return Get.dialog(
      barrierDismissible: false,
      PrimaryDialog(
        title: LocaleKeys.somethingWentWrong.tr,
        subTitle: LocaleKeys.unableToConnectToTheInternet.tr,
        btnText: LocaleKeys.ok.tr.toUpperCase(),
        onPressed: () => Get.back(),
      ),
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  static Future<dynamic> showLoadingDialog() {
    if (!_isGetReady) {
      return Future.value();
    }

    _closeOpenOverlays(closeOverlays: true);

    return Get.dialog(barrierDismissible: false, const LoadingDialog());
  }

  static void hideLoading() {
    if (_hasOpenOverlay && Get.key.currentState?.canPop() == true) {
      Get.back();
    }
  }

  /// Lock-icon "not ready yet" dialog. Lifted out of the dashboard's grid so
  /// any screen can show the same "coming soon" message for an unfinished
  /// feature, not just dashboard tiles.
  static Future<dynamic> showFeatureUnavailable(String featureName) {
    if (!_isGetReady) {
      return Future.value();
    }

    return Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFE7EEED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                color: AppColor.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              featureName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.featureTemporarilyUnavailable.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: Get.back,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                LocaleKeys.ok.tr,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showTopBanner({
    required String title,
    required String message,
    Color backgroundColor = const Color(0xFF1F2937),
    Color colorText = Colors.white,
  }) {
    if (!_isGetReady) {
      return;
    }

    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final isDuplicate =
        _lastSnackbarMessage == trimmedMessage &&
        _lastSnackbarAt != null &&
        now.difference(_lastSnackbarAt!) < const Duration(seconds: 4);
    if (isDuplicate) {
      return;
    }

    _lastSnackbarMessage = trimmedMessage;
    _lastSnackbarAt = now;

    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      trimmedMessage,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      borderRadius: 14,
      backgroundColor: backgroundColor,
      colorText: colorText,
      duration: const Duration(seconds: 3),
    );
  }
}
