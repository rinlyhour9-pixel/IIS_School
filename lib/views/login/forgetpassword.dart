// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:schoolapp/core/core.dart';
// import 'package:schoolapp/routes.dart';
// import 'package:schoolapp/views/login/widgets/socialButtonCustom.dart';
// import 'package:schoolapp/views/views.dart';

// class ForgetPasswordVies extends GetView<LoginController> {
//   const ForgetPasswordVies({super.key});

//   void loginTab() async {
//     if (!controller.formKey.currentState!.validate()) {
//       return;
//     }
//     controller.formKey.currentState!.save();
//     await controller.login();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         child: Container(
//           child: Stack(
//             children: [
//               Positioned(
//                 child: Container(
//                   child: Form(
//                     key: controller.formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         UIConstants.spacing.height,
//                         // Logo Widget
//                         SizedBox(height: 40.0),
//                         const LogoWidget(),

//                         SizedBox(height: 10.0),
//                         //card form
//                         Container(
//                           margin: const EdgeInsets.all(10.0),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             color: Colors.white,
//                           ),
//                           child: Padding(
//                             padding: UIConstants.spacing.padHorizontal,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 SizedBox(height: 10.0),
//                                 Text(
//                                   "Forget Password",
//                                   style: AppTextStyle.hugePrimaryMediumBold,
//                                 ),
//                                 UIConstants.spacing.height,
//                                 Text(
//                                   "Provide your account's phone number for reset your password.",
//                                   style: AppTextStyle.normalGreenBold,
//                                 ),
//                                 UIConstants.spacing.height,
//                                 Obx(() {
//                                   return CustomTextField(
//                                     prefixIcon: Icon(
//                                       Icons.person,
//                                       color: AppColor.primary,
//                                     ),
//                                     // controller: controller.usernameCtl,
//                                     hintText: controller.isLogVaiEmail.value
//                                         ? LocaleKeys.username.tr
//                                         : LocaleKeys.phoneNumber.tr,
//                                     validator: (text) {
//                                       if (controller.isLogVaiEmail.value) {
//                                         return FormValidator.email(
//                                           text,
//                                         ); // Validate email
//                                       }
//                                       return FormValidator.phoneNumber(text);
//                                     },
//                                   );
//                                 }),

//                                 UIConstants.spacing.height,
//                                 Obx(
//                                   () => CustomTextField(
//                                     prefixIcon: Icon(
//                                       Icons.lock,
//                                       color: AppColor.primary,
//                                     ),
//                                     controller: controller.passCtl,
//                                     hintText: LocaleKeys.password.tr,
//                                     suffixIcon: InkWell(
//                                       onTap: () =>
//                                           controller.isPassVisible.value =
//                                               !controller.isPassVisible.value,
//                                       child: Icon(
//                                         controller.isPassVisible.value
//                                             ? Icons.visibility
//                                             : Icons.visibility_off,
//                                         color: AppColor.primary,
//                                       ),
//                                     ),
//                                     obscureText: controller.isPassVisible.value,
//                                     validator: (text) =>
//                                         FormValidator.empty(text),
//                                   ),
//                                 ),
//                                 UIConstants.spacing.height,
//                                 // Toggle between login with email/phone number
//                                 //tes inkWell
//                                 // InkWell(
//                                 //   onTap: () {
//                                 //     controller.isLogVaiEmail.value =
//                                 //         !controller.isLogVaiEmail.value;
//                                 //   },
//                                 //   child: Container(
//                                 //     height: 24,
//                                 //     alignment: Alignment.center,
//                                 //     child: Obx(
//                                 //       () => Text(
//                                 //         controller.isLogVaiEmail.value
//                                 //             ? LocaleKeys.loginWithPhoneNumber.tr
//                                 //             : LocaleKeys
//                                 //                 .loginWithUsernameEmail
//                                 //                 .tr,
//                                 //         style: AppTextStyle.normalPrimaryRegular,
//                                 //       ),
//                                 //     ),
//                                 //   ),
//                                 // ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     InkWell(
//                                       child: Text(
//                                         "Forgot Password?",
//                                         style: TextStyle(
//                                           color: AppColor.primary,
//                                           fontSize: 14,
//                                           decoration: TextDecoration.underline,
//                                         ),
//                                       ),
//                                       onTap: () => Get.toNamed(Routes.register),
//                                     ),
//                                   ],
//                                 ),
//                                 UIConstants.spacing.height,
//                                 Column(
//                                   children: [
//                                     // Login button
//                                     PrimaryButton(
//                                       text: LocaleKeys.login.tr,
//                                       // onPressed: loginTab,
//                                       onPressed: () =>
//                                           Get.toNamed(Routes.start),
//                                     ),

//                                     SizedBox(height: 4.0),
//                                     // Register text widget
//                                   ],
//                                 ),
//                                 UIConstants.spacing.height,
//                                 Center(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         "Don't Have Account?",
//                                         style: AppTextStyle.normalGreenRegular,
//                                       ),
//                                       SizedBox(width: 10),
//                                       InkWell(
//                                         onTap: () =>
//                                             Get.toNamed(Routes.register),

//                                         child: Text(
//                                           "Sign Up",
//                                           style: TextStyle(
//                                             color: AppColor.primary,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                             decoration:
//                                                 TextDecoration.underline,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(height: 2),
//                               ],
//                             ),
//                           ),
//                         ),
//                         // Expands to fill remaining space
//                         UIConstants.spacing.height,
//                         SocialButtonCustomWidget(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
