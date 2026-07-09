import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/login/widgets/inline_language_dropdown.dart';
import 'package:schoolapp/views/login/widgets/role_switch_label.dart';
import 'package:schoolapp/views/login/widgets/socialButtonCustom.dart';
import 'package:schoolapp/views/views.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  void registerTap() async {
    await controller.register();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottomInset + 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      UIConstants.spacing.height,
                      const SizedBox(height: 40.0),
                      Hero(
                        tag: 'app_logo_hero',
                        child: ClipOval(
                          child: Image.asset(
                            AssetPath.appLogo.path,
                            height: 110,
                            width: 110,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      10.height,
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: UIConstants.spacing.padHorizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10.0),
                              Text(
                                textAlign: TextAlign.center,
                                LocaleKeys.signUp.tr,
                                style: AppTextStyle.hugePrimaryMediumBold,
                              ),
                              UIConstants.spacingSmall.height,
                              Text(
                                LocaleKeys.loginContinueMessage.tr,
                                style: AppTextStyle.normalGreenRegular,
                                textAlign: TextAlign.center,
                              ),
                              UIConstants.spacing.height,
                              Obx(() {
                                final selected =
                                    controller.selectedRegisterRole.value;
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width =
                                        constraints.maxWidth > 0
                                            ? constraints.maxWidth
                                            : MediaQuery.of(
                                                  context,
                                                ).size.width -
                                                56;
                                    final indicatorWidth = (width - 8) / 2;
                                    final isTeacher =
                                        selected == UserType.teacher;

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: SizedBox(
                                        height: 52,
                                        child: Stack(
                                          children: [
                                            AnimatedPositioned(
                                              duration: const Duration(
                                                milliseconds: 280,
                                              ),
                                              curve: Curves.easeInOutCubic,
                                              left:
                                                  isTeacher
                                                      ? 0
                                                      : indicatorWidth,
                                              top: 0,
                                              bottom: 0,
                                              child: Container(
                                                width: indicatorWidth,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF0A6A5E),
                                                          Color(0xFF024139),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end:
                                                            Alignment
                                                                .bottomRight,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Expanded(
                                            //       child: RoleSwitchLabel(
                                            //         label:
                                            //             LocaleKeys.teacher.tr,
                                            //         icon: Icons.school,
                                            //         isSelected: isTeacher,
                                            //         onTap:
                                            //             () => controller
                                            //                 .setRegisterRole(
                                            //                   UserType.teacher,
                                            //                 ),
                                            //       ),
                                            //     ),
                                            //     Expanded(
                                            //       child: RoleSwitchLabel(
                                            //         label: LocaleKeys.parent.tr,
                                            //         icon: Icons.groups,
                                            //         isSelected: !isTeacher,
                                            //         onTap:
                                            //             () => controller
                                            //                 .setRegisterRole(
                                            //                   UserType.parent,
                                            //                 ),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                              const SizedBox(height: 15),
                              Obx(
                                () => CustomTextField(
                                  key: ValueKey(
                                    'register_name_${controller.selectedRegisterRole.value.key}',
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: AppColor.primary,
                                  ),
                                  controller: controller.nameCon,
                                  hintText: LocaleKeys.enterYourName.tr,
                                  filled: true,
                                  borderRadius: BorderRadius.circular(22),
                                  borderColor: const Color(0xFFC9CFD8),
                                  enabledBorderColor: const Color(0xFFC9CFD8),
                                  focusedBorderColor: AppColor.primary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  errorText: controller.nameError.value,
                                  onChanged:
                                      (val) =>
                                          controller.nameError.value = null,
                                  validator: FormValidator.empty,
                                ),
                              ),
                              UIConstants.spacing.height,
                              Obx(() {
                                final isParent =
                                    controller.selectedRegisterRole.value ==
                                    UserType.parent;
                                return CustomTextField(
                                  key: ValueKey(
                                    'register_identity_${controller.selectedRegisterRole.value.key}',
                                  ),
                                  prefixIcon: Icon(
                                    isParent ? Icons.phone : Icons.person,
                                    color: AppColor.primary,
                                  ),
                                  controller: controller.identityCon,
                                  hintText:
                                      isParent
                                          ? LocaleKeys.phoneNumber.tr
                                          : LocaleKeys.phoneOrEmail.tr,
                                  filled: true,
                                  borderRadius: BorderRadius.circular(22),
                                  borderColor: const Color(0xFFC9CFD8),
                                  enabledBorderColor: const Color(0xFFC9CFD8),
                                  focusedBorderColor: AppColor.primary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  errorText: controller.identityError.value,
                                  onChanged:
                                      (val) =>
                                          controller.identityError.value = null,
                                  keyboardType:
                                      isParent
                                          ? TextInputType.phone
                                          : TextInputType.text,
                                  inputFormatters:
                                      isParent
                                          ? [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                              12,
                                            ),
                                          ]
                                          : null,
                                  validator: controller.validateIdentity,
                                );
                              }),
                              UIConstants.spacing.height,
                              Obx(
                                () => CustomTextField(
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: AppColor.primary,
                                  ),
                                  controller: controller.passCon,
                                  hintText: LocaleKeys.password.tr,
                                  errorText: controller.passwordError.value,
                                  onChanged:
                                      (val) =>
                                          controller.passwordError.value = null,
                                  obscureText: controller.isPassVisible.value,
                                  filled: true,
                                  borderRadius: BorderRadius.circular(22),
                                  borderColor: const Color(0xFFC9CFD8),
                                  enabledBorderColor: const Color(0xFFC9CFD8),
                                  focusedBorderColor: AppColor.primary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  suffixIcon: SizedBox(
                                    width: 62,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 1,
                                          height: 22,
                                          color: const Color(0xFFD6DBE3),
                                        ),
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap:
                                              () =>
                                                  controller
                                                      .isPassVisible
                                                      .value = !controller
                                                          .isPassVisible
                                                          .value,
                                          child: Icon(
                                            controller.isPassVisible.value
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: const Color(0xFF8F97A5),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                  validator: FormValidator.empty,
                                ),
                              ),
                              UIConstants.spacing.height,
                              Obx(
                                () => CustomTextField(
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: AppColor.primary,
                                  ),
                                  controller: controller.confirmCon,
                                  hintText: LocaleKeys.confirmPassword.tr,
                                  errorText:
                                      controller.confirmPasswordError.value,
                                  onChanged:
                                      (val) =>
                                          controller
                                              .confirmPasswordError
                                              .value = null,
                                  obscureText:
                                      controller.isPassVisibleConfirm.value,
                                  filled: true,
                                  borderRadius: BorderRadius.circular(22),
                                  borderColor: const Color(0xFFC9CFD8),
                                  enabledBorderColor: const Color(0xFFC9CFD8),
                                  focusedBorderColor: AppColor.primary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  suffixIcon: SizedBox(
                                    width: 62,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 1,
                                          height: 22,
                                          color: const Color(0xFFD6DBE3),
                                        ),
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap:
                                              () =>
                                                  controller
                                                      .isPassVisibleConfirm
                                                      .value = !controller
                                                          .isPassVisibleConfirm
                                                          .value,
                                          child: Icon(
                                            controller
                                                    .isPassVisibleConfirm
                                                    .value
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: const Color(0xFF8F97A5),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                  validator:
                                      (text) => FormValidator.equalValues(
                                        original: controller.passCon.text,
                                        confirm: text,
                                      ),
                                ),
                              ),
                              UIConstants.spacing.height,
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [InlineLanguageDropdown()],
                              ),
                              UIConstants.spacing.height,
                              Obx(() {
                                final isLoading = controller.isLoading.value;
                                return SizedBox(
                                  width: double.infinity,
                                  height: UIConstants.btnHeight,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : registerTap,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primary,
                                      disabledBackgroundColor: AppColor.primary
                                          .withOpacity(0.8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            UIConstants.radius.radiusAll,
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      child:
                                          isLoading
                                              ? Row(
                                                key: const ValueKey('loading'),
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.4,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    LocaleKeys.signingIn.tr,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              )
                                              : Text(
                                                LocaleKeys.signUp.tr,
                                                key: const ValueKey('idle'),
                                                style:
                                                    AppTextStyle
                                                        .normalWhiteBold,
                                              ),
                                    ),
                                  ),
                                );
                              }),
                              UIConstants.spacing.height,
                              Center(
                                child: Column(
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 10,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          LocaleKeys.haveAnAccount.tr,
                                          style:
                                              AppTextStyle.normalGreenRegular,
                                        ),
                                        InkWell(
                                          onTap: Get.back,
                                          child: Text(
                                            LocaleKeys.login.tr,
                                            style: const TextStyle(
                                              color: AppColor.primary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      LocaleKeys.orConnectWith.tr,
                                      style: AppTextStyle.normalGreenRegular,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      UIConstants.spacingSmall.height,

                      const SocialButtonCustomWidget(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
