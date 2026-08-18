import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schoolapp/core/core.dart';

class ProfileController extends GetxController {
  final Rxn<XFile> profile = Rxn<XFile>(XFile(''));
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    notificationsEnabled.value =
        await HomeworkNotificationService.instance.isEnabled();
  }

  Future<void> toggleNotifications(bool enabled) async {
    notificationsEnabled.value = enabled;
    await HomeworkNotificationService.instance.setEnabled(enabled);
  }

  Future<void> showNotificationDebug() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    final fcmToken = await FcmTokenSyncService.instance.getCurrentToken();
    final enabled = await HomeworkNotificationService.instance.isEnabled();

    Get.dialog(
      AlertDialog(
        title: const Text('Notification Debug'),
        content: SingleChildScrollView(
          child: SelectableText(
            [
              'enabled: $enabled',
              'permission: ${settings.authorizationStatus.name}',
              'alert: ${settings.alert.name}',
              'badge: ${settings.badge.name}',
              'sound: ${settings.sound.name}',
              'apns_token: ${apnsToken ?? '(empty)'}',
              'fcm_token: ${fcmToken ?? '(empty)'}',
            ].join('\n\n'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await HomeworkNotificationService.instance
                  .showTestHomeworkNotification();
            },
            child: const Text('Test local'),
          ),
          TextButton(
            onPressed: Get.back,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> updateProfile(XFile file) async {
    try {
      final dio.FormData formData = dio.FormData.fromMap({
        'name': UserRepository.shared.profile.name,
        'profile': await dio.MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
      });

      await Get.find<ApiService>().post(
        EndPoints.updateProfile,
        formData,
        isShowLoading: true,
        cusHeaders: {'Content-Type': 'multipart/form-data'},
      );

      profile.value = file;

      DialogManager.hideLoading();
    } catch (e) {
      if (isClosed) {
        return;
      }
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await UserRepository.shared.deleteAccount();
    } catch (e) {
      if (isClosed) {
        return;
      }
      ExceptionHandler.handleException(e);
    }
  }
}
