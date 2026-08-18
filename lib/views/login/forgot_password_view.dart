import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/routes.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _phoneCtl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSending) return;

    setState(() => _isSending = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSending = false);

    DialogManager.showDialog(
      title: LocaleKeys.successfully.tr,
      subTitle: LocaleKeys.verificationCodeSent.tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 22),
                Text(
                  LocaleKeys.forgotPassword.tr,
                  style: AppTextStyle.hugePrimaryMediumBold,
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.forgotPasswordDescription.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.primary),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.asset(
                          AssetPath.cambodiaFlag.path,
                          width: 26,
                          height: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(width: 1, height: 18, color: AppColor.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: LocaleKeys.phoneNumber.tr,
                            hintStyle: AppTextStyle.normalLightGreyRegular,
                          ),
                          validator: FormValidator.phoneNumber,
                        ),
                      ),
                    ],
                  ),
                ),
                24.height,
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isSending
                          ? LocaleKeys.signingIn.tr
                          : LocaleKeys.sendCode.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 28 * 0.64,
                      ),
                    ),
                  ),
                ),
                30.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.rememberYourPassword.tr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16 * 0.95,
                      ),
                    ),
                    InkWell(
                      onTap: Get.back,
                      child: Text(
                        LocaleKeys.backToLogin.tr,
                        style: const TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          fontSize: 16 * 0.95,
                        ),
                      ),
                    ),
                  ],
                ),
                12.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.needHelp.tr,
                      style: const TextStyle(fontSize: 16 * 0.95),
                    ),
                    InkWell(
                      onTap: () => Get.toNamed(Routes.contactUs),
                      child: Text(
                        LocaleKeys.contactSupport.tr,
                        style: const TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          fontSize: 16 * 0.95,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
