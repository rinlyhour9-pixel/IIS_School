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
