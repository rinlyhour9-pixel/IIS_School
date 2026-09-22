import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/login/widgets/inline_language_dropdown.dart';
import 'package:schoolapp/views/login/widgets/role_switch_label.dart';
import 'package:schoolapp/views/login/widgets/socialButtonCustom.dart';
import 'package:schoolapp/views/views.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  void loginTab() async {
    if (!controller.formKey.currentState!.validate()) {
      return;
    }
    controller.formKey.currentState!.save();
    await controller.login();
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10.0),
                              Text(
                                LocaleKeys.loginNow.tr,
                                style: AppTextStyle.hugePrimaryMediumBold,
                              ),
                              UIConstants.midSpacing.height,
                              Text(
                                LocaleKeys.loginContinueMessage.tr,
                                style: AppTextStyle.normalGreenRegular,
                              ),
                              UIConstants.spacing.height,
                              // Obx(() {
                              //   final selected =
                              //       controller.selectedLoginRole.value;
                              //   return LayoutBuilder(
                              //     builder: (context, constraints) {
                              //       final width =
                              //           constraints.maxWidth > 0
                              //               ? constraints.maxWidth
                              //               : MediaQuery.of(
                              //                     context,
                              //                   ).size.width -
                              //                   56;
                              //       final indicatorWidth = (width - 8) / 2;
                              //       final isTeacher =
                              //           selected == UserType.teacher;

                              //       return Container(
                              //         width: double.infinity,
                              //         decoration: BoxDecoration(
                              //           color: Colors.white,
                              //           borderRadius: BorderRadius.circular(
                              //             999,
                              //           ),
                              //         ),
                              //         padding: const EdgeInsets.all(4),
                              //         child: SizedBox(
                              //           height: 52,
                              //           child: Stack(
                              //             children: [
                              //               AnimatedPositioned(
                              //                 duration: const Duration(
                              //                   milliseconds: 280,
                              //                 ),
                              //                 curve: Curves.easeInOutCubic,
                              //                 left:
                              //                     isTeacher
                              //                         ? 0
                              //                         : indicatorWidth,
                              //                 top: 0,
                              //                 bottom: 0,
                              //                 child: Container(
                              //                   width: indicatorWidth,
                              //                   decoration: BoxDecoration(
                              //                     borderRadius:
                              //                         BorderRadius.circular(
                              //                           999,
                              //                         ),
                              //                     gradient:
                              //                         const LinearGradient(
                              //                           colors: [
                              //                             Color(0xFF0A6A5E),
                              //                             Color(0xFF024139),
                              //                           ],
                              //                           begin:
                              //                               Alignment.topLeft,
                              //                           end:
                              //                               Alignment
                              //                                   .bottomRight,
                              //                         ),
                              //                   ),
                              //                 ),
                              //               ),
                              //               // Row(
                              //               //   children: [
                              //               //     Expanded(
                              //               //       child: RoleSwitchLabel(
                              //               //         label:
                              //               //             LocaleKeys
                              //               //                 .teacher
                              //               //                 .tr,
                              //               //         icon: Icons.school,
                              //               //         isSelected: isTeacher,
                              //               //         onTap:
                              //               //             () => controller
                              //               //                 .setLoginRole(
                              //               //                   UserType
                              //               //                       .teacher,
                              //               //                 ),
                              //               //       ),
                              //               //     ),
                              //               //     Expanded(
                              //               //       child: RoleSwitchLabel(
                              //               //         label:
                              //               //             LocaleKeys
                              //               //                 .parent
                              //               //                 .tr,
                              //               //         icon: Icons.groups,
                              //               //         isSelected: !isTeacher,
                              //               //         onTap:
                              //               //             () => controller
                              //               //                 .setLoginRole(
                              //               //                   UserType
                              //               //                       .parent,
                              //               //                 ),
                              //               //       ),
                              //               //     ),
                              //               //   ],
                              //               // ),
                              //             ],
                              //           ),
                              //         ),
                              //       );
                              //     },
                              //   );
                              // }),
                              const SizedBox(height: 15),
                              Obx(
                                () => CustomTextField(
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: AppColor.primary,
                                  ),
                                  controller: controller.emailCtl,
                                  hintText: LocaleKeys.phoneOrEmail.tr,
                                  filled: true,
                                  borderRadius: BorderRadius.circular(22),
                                  borderColor: const Color(0xFFC9CFD8),
                                  enabledBorderColor: const Color(0xFFC9CFD8),
                                  focusedBorderColor: AppColor.primary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  suffixIcon:
                                      controller.hasEmailText.value
                                          ? IconButton(
                                            onPressed: () {
                                              controller.emailCtl.clear();
                                              controller.emailError.value =
                                                  null;
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Color(0xFF8F97A5),
                                            ),
                                          )
                                          : null,
                                  errorText: controller.emailError.value,
                                  onChanged:
                                      (val) =>
                                          controller.emailError.value = null,
                                  keyboardType: TextInputType.text,
                                  validator: controller.validateIdentity,
                                ),
                              ),
                              UIConstants.spacing.height,
                              Obx(
                                () => CustomTextField(
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: AppColor.primary,
                                  ),
                                  controller: controller.passCtl,
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
                                    width:
                                        controller.hasPasswordText.value
                                            ? 104
                                            : 62,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (controller
                                            .hasPasswordText
                                            .value) ...[
                                          InkWell(
                                            onTap: () {
                                              controller.passCtl.clear();
                                              controller.passwordError.value =
                                                  null;
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              color: Color(0xFF8F97A5),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
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
                                  validator:
                                      (text) => FormValidator.empty(text),
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
                                    onPressed: isLoading ? null : loginTab,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primary,
                                      disabledBackgroundColor: AppColor.primary
                                          .withValues(alpha: 0.8),
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
                                                LocaleKeys.login.tr,
                                                key: const ValueKey('idle'),
                                                style:
                                                    AppTextStyle
                                                        .normalWhiteBold,
                                              ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                      ),
                      UIConstants.spacing.height,
                      const SizedBox(height: 12),
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
