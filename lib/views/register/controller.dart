import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/resources/locales.g.dart';
import 'package:schoolapp/core/constants/constants.dart';
import 'package:schoolapp/core/utils/form_validator.dart';
import 'package:schoolapp/core/utils/dialog_manager.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameCon = TextEditingController();
  final TextEditingController identityCon = TextEditingController();
  final TextEditingController passCon = TextEditingController();
  final TextEditingController confirmCon = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPassVisible = true.obs;
  final RxBool isPassVisibleConfirm = true.obs;
  final selectedRegisterRole = UserType.parent.obs;

  final RxnString nameError = RxnString();
  final RxnString identityError = RxnString();
  final RxnString passwordError = RxnString();
  final RxnString confirmPasswordError = RxnString();

  @override
  void onClose() {
    nameCon.dispose();
    identityCon.dispose();
    passCon.dispose();
    confirmCon.dispose();
    super.onClose();
  }

  void setRegisterRole(UserType role) {
    if (selectedRegisterRole.value == role) return;
    selectedRegisterRole.value = role;
    formKey.currentState?.reset();
    _clearAllInputs();
    _clearErrors();
  }

  void refreshValidationMessages() {
    _clearErrors();
    formKey.currentState?.validate();
  }

  /// The sign up screen is display only: no account is created from the app.
  Future<void> register() async {
    DialogManager.showDialog(
      title: LocaleKeys.signUp.tr,
      subTitle: LocaleKeys.registerUnavailable.tr,
    );
  }

  String? validateIdentity(String? text) {
    final identity = (text ?? '').trim();
    if (selectedRegisterRole.value == UserType.parent) {
      return FormValidator.phoneNumber(identity);
    }

    final emptyCheck = FormValidator.empty(identity);
    if (emptyCheck != null) return emptyCheck;

    if (_isLikelyPhone(identity) || _isLikelyEmail(identity)) {
      return null;
    }
    return null;
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

  String _normalizePhone(String text) {
    return text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  void _clearAllInputs() {
    nameCon.clear();
    identityCon.clear();
    passCon.clear();
    confirmCon.clear();
  }

  void _clearErrors() {
    nameError.value = null;
    identityError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;
  }
}
