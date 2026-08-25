import 'dart:async';

import 'package:dio/dio.dart' as d;
import 'package:schoolapp/core/libraries/shared_preferences.dart';
import 'package:schoolapp/core/resources/resources.dart';
import 'package:schoolapp/core/services/end_points.dart';
import 'package:schoolapp/core/services/class_topic_subscription_service.dart';
import 'package:schoolapp/core/services/fcm_token_sync_service.dart';
import 'package:schoolapp/core/services/selected_student_service.dart';
import 'package:schoolapp/core/utils/exception_manager.dart';
import 'package:schoolapp/core/utils/form_validator.dart';
import 'package:schoolapp/core/constants/constants.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:schoolapp/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:schoolapp/views/views.dart';
import 'package:get/get.dart';

import '../../../core/services/api_service.dart';
import '../../../core/utils/dialog_manager.dart';
import '../../../core/repositories/user.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailCtl = TextEditingController();
  final TextEditingController passCtl = TextEditingController();

  var isLoading = false.obs;
  var isPassVisible = true.obs;

  var emailError = RxnString();
  var passwordError = RxnString();
  final hasEmailText = false.obs;
  final hasPasswordText = false.obs;
  // final selectedLoginRole = UserType.parent.obs;

  @override
  void onInit() {
    super.onInit();
    emailCtl.addListener(() => hasEmailText.value = emailCtl.text.isNotEmpty);
    passCtl.addListener(() => hasPasswordText.value = passCtl.text.isNotEmpty);
  }

  @override
  void onClose() {
    emailCtl.dispose();
    passCtl.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    if (isLoading.value) return;

    final String loginIdentity = emailCtl.text.trim();
    final String password = passCtl.text.trim();

    try {
      isLoading.value = true;
      final fcmToken = await _getFcmToken();
      final deviceName = _deviceName;
      debugPrint('FCM token: $fcmToken');

      final response = await _loginByRole(
        loginIdentity: loginIdentity,
        password: password,
        fcmToken: fcmToken,
        deviceName: deviceName,
      );
      if (response == null) {
        DialogManager.showDialog(
          title: LocaleKeys.error.tr,
          subTitle: LocaleKeys.noResponseFromServer.tr,
        );
        return;
      }

      ///  check success
      if (response['success'] != true) {
        DialogManager.showDialog(
          title: LocaleKeys.loginFailed.tr,
          subTitle: _localizedLoginMessage(response['message']),
        );
        return;
      }

      final data = response['data'];

      if (data == null) {
        DialogManager.showDialog(
          title: LocaleKeys.error.tr,
          subTitle: LocaleKeys.invalidServerResponse.tr,
        );
        return;
      }

      final String token = data['token']?.toString() ?? '';
      final String role = (data['role'] ?? '').toString().toLowerCase();
      final String name = data['name']?.toString() ?? '';
      final String profile = _firstNonEmpty([
        data['profile'],
        data['profile_path'],
        data['avatar'],
        data['photo'],
        data['image'],
      ]);
      final String userId =
          (data['user_id'] ?? data['id'] ?? '').toString().trim();
      final String staffCode =
          (data['staff_code'] ?? data['code'] ?? data['id'] ?? '')
              .toString()
              .trim();
      final String branchId =
          ((data['branches'] is Map) ? (data['branches']['id'] ?? '') : '')
              .toString()
              .trim();

      final String scannerOwnerId = _resolveScannerOwnerId(
        data: data,
        fallbackUsername: loginIdentity,
      );

      if (token.isEmpty) {
        DialogManager.showDialog(
          title: LocaleKeys.loginFailed.tr,
          subTitle: LocaleKeys.tokenMissing.tr,
        );
        return;
      }

      ///  role check
      final allowedRoles = UserType.allowedRoleKeys;

      if (!allowedRoles.contains(role)) {
        DialogManager.showDialog(
          title: LocaleKeys.permission.tr,
          subTitle: LocaleKeys.noPermission.tr,
        );
        return;
      }

      // if (role != selectedLoginRole.value.key) {
      //   DialogManager.showDialog(
      //     title: LocaleKeys.loginFailed.tr,
      //     subTitle:
      //         '${LocaleKeys.selectedRoleIs.tr} ${selectedLoginRole.value.key}. ${LocaleKeys.pleaseSwitchRoleAndTryAgain.tr}',
      //   );
      //   return;
      // }

      UserRepository.shared.setUserType(role);
      AppConfig.shared.token = token;

      await SharedPreferencesManager.setValue('token', token);
      await SharedPreferencesManager.setValue('username', loginIdentity);
      await SharedPreferencesManager.setValue('password', password);
      await SharedPreferencesManager.setValue('name', name);
      await SharedPreferencesManager.setValue('profile', profile);
      await SharedPreferencesManager.setValue('user_id', userId);
      await SharedPreferencesManager.setValue('staff_code', staffCode);
      await SharedPreferencesManager.setValue('user_role', role);
      await SharedPreferencesManager.setValue(
        'scanner_owner_id',
        scannerOwnerId,
      );
      await SharedPreferencesManager.setValue('staff_code', staffCode);
      await SharedPreferencesManager.setValue('branch_id', branchId);

      await Get.updateLocale(AppConfig.shared.languageLocale);

      Get.delete<StartController>(force: true);
      Get.delete<DashboardController>(force: true);
      Get.delete<ProfileController>(force: true);
      Get.delete<PaymentHistoryController>(force: true);

      Get.offAllNamed(Routes.start);

      unawaited(_postLoginSetup());
    } catch (e) {
      DialogManager.showDialog(
        title: LocaleKeys.error.tr,
        subTitle: LocaleKeys.somethingWentWrongTryAgain.tr,
      );

      ExceptionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await ClassTopicSubscriptionService.instance.clearSubscription();
    if (Get.isRegistered<SelectedStudentService>()) {
      await Get.find<SelectedStudentService>().clear();
    }
    await SharedPreferencesManager.clear();
    AppConfig.shared.token = '';

    Get.delete<StartController>(force: true);
    Get.delete<DashboardController>(force: true);
    Get.delete<ProfileController>(force: true);
    Get.delete<PaymentHistoryController>(force: true);

    Get.offAllNamed(Routes.login);
  }

  String _resolveScannerOwnerId({
    required dynamic data,
    required String fallbackUsername,
  }) {
    if (data is! Map<String, dynamic>) {
      return fallbackUsername;
    }

    final candidates = <dynamic>[
      data['staff_code'],
      data['card_uid'],
      data['code'],
      data['user_code'],
      data['employee_code'],
      data['id'],
      data['username'],
      fallbackUsername,
    ];

    for (final value in candidates) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return fallbackUsername;
  }

  // void setLoginRole(UserType role) {
  //   if (selectedLoginRole.value == role) return;
  //   selectedLoginRole.value = role;
  //   formKey.currentState?.reset();
  //   emailCtl.clear();
  //   passCtl.clear();
  //   emailError.value = null;
  //   passwordError.value = null;
  // }

  void refreshValidationMessages() {
    emailError.value = null;
    passwordError.value = null;
    formKey.currentState?.validate();
  }

  // Future<dynamic> _loginByRole({
  //   required String loginIdentity,
  //   required String password,
  //   required String fcmToken,
  //   required String deviceName,
  // }) async {
  //   if (selectedLoginRole.value == UserType.parent) {
  //     return _loginWithPhone(
  //       loginIdentity: loginIdentity,
  //       password: password,
  //       fcmToken: fcmToken,
  //       deviceName: deviceName,
  //     );
  //   }
  //   return _loginTeacher(
  //     loginIdentity: loginIdentity,
  //     password: password,
  //     fcmToken: fcmToken,
  //     deviceName: deviceName,
  //   );
  // }

  Future<dynamic> _loginByRole({
    required String loginIdentity,
    required String password,
    required String fcmToken,
    required String deviceName,
  }) async {
    final parentAttempts = _parentAttempts(
      loginIdentity: loginIdentity,
      password: password,
      fcmToken: fcmToken,
      deviceName: deviceName,
    );
    final teacherAttempts = _teacherAttempts(
      loginIdentity: loginIdentity,
      password: password,
      fcmToken: fcmToken,
      deviceName: deviceName,
    );

    final attempts =
        _isLikelyPhone(loginIdentity)
            ? <Map<String, dynamic>>[...parentAttempts, ...teacherAttempts]
            : <Map<String, dynamic>>[...teacherAttempts, ...parentAttempts];
    return _performLoginAttempts(attempts);
  }

  Future<String> _getFcmToken() async {
    try {
      return await FcmTokenSyncService.instance.getCurrentToken() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _postLoginSetup() async {
    try {
      await Future.wait([
        FcmTokenSyncService.instance.syncCurrentTokenIfAuthenticated(
          force: true,
        ),
        ClassTopicSubscriptionService.instance.syncSelectedClassTopic(),
      ]);

      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().fetchSliders();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Post-login setup failed: $e');
      }
    }
  }

  // Future<dynamic> _loginWithPhone({
  //   required String loginIdentity,
  //   required String password,
  //   required String fcmToken,
  //   required String deviceName,
  // }) async {
  //   final rawPhone = loginIdentity.trim();
  //   final normalizedPhone = _normalizePhone(loginIdentity);

  //   if (!_isLikelyPhone(loginIdentity)) {
  //     return {
  //       "success": false,
  //       "message": LocaleKeys.pleaseEnterValidPhoneNumber.tr,
  //     };
  //   }

  //   final attempts = <Map<String, dynamic>>[
  //     {
  //       "phone": rawPhone,
  //       "phone_number": rawPhone,
  //       "username": rawPhone,
  //       "password": password,
  //       "fcm_token": fcmToken,
  //       "device_name": deviceName,
  //     },
  //     if (normalizedPhone != rawPhone)
  //       {
  //         "phone": normalizedPhone,
  //         "phone_number": normalizedPhone,
  //         "username": normalizedPhone,
  //         "password": password,
  //         "fcm_token": fcmToken,
  //         "device_name": deviceName,
  //       },
  //   ];

  //   return _performLoginAttempts(attempts);
  // }

  // Future<dynamic> _loginTeacher({
  //   required String loginIdentity,
  //   required String password,
  //   required String fcmToken,
  //   required String deviceName,
  // }) async {
  //   final attempts = <Map<String, dynamic>>[];
  //   final rawIdentity = loginIdentity.trim();
  //   final normalizedPhone = _normalizePhone(loginIdentity);
  //   final normalizedEmail = loginIdentity.trim().toLowerCase();

  //   attempts.add({
  //     "username": rawIdentity,
  //     if (_isLikelyEmail(loginIdentity)) "email": normalizedEmail,
  //     "phone": rawIdentity,
  //     "phone_number": rawIdentity,
  //     "password": password,
  //     "fcm_token": fcmToken,
  //     "device_name": deviceName,
  //   });

  //   if (_isLikelyPhone(loginIdentity) && normalizedPhone != rawIdentity) {
  //     attempts.add({
  //       "username": normalizedPhone,
  //       "phone": normalizedPhone,
  //       "phone_number": normalizedPhone,
  //       "password": password,
  //       "fcm_token": fcmToken,
  //       "device_name": deviceName,
  //     });
  //   }

  //   return _performLoginAttempts(attempts);
  // }

  List<Map<String, dynamic>> _parentAttempts({
    required String loginIdentity,
    required String password,
    required String fcmToken,
    required String deviceName,
  }) {
    if (!_isLikelyPhone(loginIdentity)) return [];

    final rawPhone = loginIdentity.trim();
    final normalizedPhone = _normalizePhone(loginIdentity);

    return [
      {
        "phone": rawPhone,
        "phone_number": rawPhone,
        "username": rawPhone,
        "password": password,
        "fcm_token": fcmToken,
        "device_name": deviceName,
      },
      if (normalizedPhone != rawPhone)
        {
          "phone": normalizedPhone,
          "phone_number": normalizedPhone,
          "username": normalizedPhone,
          "password": password,
          "fcm_token": fcmToken,
          "device_name": deviceName,
        },
    ];
  }

  List<Map<String, dynamic>> _teacherAttempts({
    required String loginIdentity,
    required String password,
    required String fcmToken,
    required String deviceName,
  }) {
    final attempts = <Map<String, dynamic>>[];
    final rawIdentity = loginIdentity.trim();
    final normalizedPhone = _normalizePhone(loginIdentity);
    final normalizedEmail = loginIdentity.trim().toLowerCase();

    attempts.add({
      "username": rawIdentity,
      if (_isLikelyEmail(loginIdentity)) "email": normalizedEmail,
      "phone": rawIdentity,
      "phone_number": rawIdentity,
      "password": password,
      "fcm_token": fcmToken,
      "device_name": deviceName,
    });

    if (_isLikelyPhone(loginIdentity) && normalizedPhone != rawIdentity) {
      attempts.add({
        "username": normalizedPhone,
        "phone": normalizedPhone,
        "phone_number": normalizedPhone,
        "password": password,
        "fcm_token": fcmToken,
        "device_name": deviceName,
      });
    }

    return attempts;
  }

  Future<dynamic> _performLoginAttempts(
    List<Map<String, dynamic>> attempts,
  ) async {
    final api = Get.find<ApiService>();
    final seenPayloads = <String>{};
    dynamic bestFailure = {
      "success": false,
      "message": LocaleKeys.loginFailed.tr,
    };

    for (final payload in attempts) {
      final filteredPayload = Map<String, dynamic>.fromEntries(
        payload.entries.where(
          (entry) =>
              entry.value != null && entry.value.toString().trim().isNotEmpty,
        ),
      );
      final payloadKey = filteredPayload.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
      if (!seenPayloads.add(payloadKey)) {
        continue;
      }

      try {
        final res = await api.post(
          EndPoints.login,
          filteredPayload,
          isShowLoading: true,
        );
        final response = res.data;
        if (response is Map && response['success'] == true) {
          return response;
        }
        if (_preferFailure(response, bestFailure)) {
          bestFailure = response;
        }
      } on d.DioException catch (e) {
        final failure =
            e.response?.data ??
            {
              "success": false,
              "message": e.message ?? LocaleKeys.loginFailed.tr,
            };
        if (_preferFailure(failure, bestFailure)) {
          bestFailure = failure;
        }
      }
    }

    return bestFailure;
  }

  String get _deviceName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  bool _preferFailure(dynamic candidate, dynamic current) {
    final candidateMessage = _extractErrorMessage(candidate);
    final currentMessage = _extractErrorMessage(current);
    if (candidateMessage.isEmpty) {
      return false;
    }
    if (currentMessage.isEmpty) {
      return true;
    }
    final candidateGeneric = _isGenericLoginMessage(candidateMessage);
    final currentGeneric = _isGenericLoginMessage(currentMessage);
    if (candidateGeneric == currentGeneric) {
      return candidateMessage.length > currentMessage.length;
    }
    return !candidateGeneric;
  }

  String _extractErrorMessage(dynamic response) {
    if (response is Map) {
      final message =
          response['message'] ?? response['error'] ?? response['detail'] ?? '';
      return message.toString().trim();
    }
    return (response ?? '').toString().trim();
  }

  bool _isGenericLoginMessage(String message) {
    final lower = message.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'login failed' ||
        lower == 'invalid credentials' ||
        lower == 'invalid credential' ||
        lower == 'unauthorized' ||
        lower == 'error';
  }

  bool _isLikelyPhone(String text) {
    return RegExp(r'^\+?\d{6,15}$').hasMatch(_normalizePhone(text));
  }

  bool _isLikelyEmail(String text) {
    return RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
      caseSensitive: false,
    ).hasMatch(text.trim());
  }

  // String? validateIdentity(String? text) {
  //   final identity = (text ?? '').trim();
  //   if (selectedLoginRole.value == UserType.parent) {
  //     return FormValidator.phoneNumber(identity);
  //   }

  //   final emptyCheck = FormValidator.empty(identity);
  //   if (emptyCheck != null) return emptyCheck;

  //   return null;
  // }

  String? validateIdentity(String? text) {
    return FormValidator.empty((text ?? '').trim());
  }

  String _normalizePhone(String text) {
    return text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty &&
          text.toLowerCase() != 'null' &&
          text.toLowerCase() != 'n/a') {
        return text;
      }
    }
    return '';
  }

  String _localizedLoginMessage(dynamic rawMessage) {
    final message = (rawMessage ?? '').toString().trim();
    final lower = message.toLowerCase();

    if (message.isEmpty) {
      return LocaleKeys.invalidCredentials.tr;
    }
    if (lower.contains('invalid') && lower.contains('credential')) {
      return LocaleKeys.invalidCredentials.tr;
    }
    if (lower == 'login failed' || lower.contains('login failed')) {
      return LocaleKeys.loginFailedMessage.tr;
    }
    if (lower.contains('valid phone')) {
      return LocaleKeys.pleaseEnterValidPhoneNumber.tr;
    }
    if (lower.contains('no response')) {
      return LocaleKeys.noResponseFromServer.tr;
    }
    return message;
  }
}
