import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/start/widgets/custom_appbar.dart';
import 'package:schoolapp/views/views.dart';

class StartView extends GetView<StartController> {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final navFontSize =
        screenWidth < 350 ? 10.0 : (screenWidth < 390 ? 10.8 : 11.5);

    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;
      final isParent = controller.isParentUser.value;
      final showCustomAppBar = selectedIndex == 0;
      final roleWelcomePrefix =
          isParent
              ? LocaleKeys.welcomeParentPrefix.tr
              : LocaleKeys.welcomeTeacherPrefix.tr;
      final roleSubTitle =
          isParent
              ? LocaleKeys.welcomeParentSubtitle.tr
              : LocaleKeys.welcomeTeacherSubtitle.tr;
      return PopScope(
        canPop: selectedIndex == 0,
        onPopInvoked: (didPop) {
          controller.handleClickBack();
        },
        child: Scaffold(
          extendBody: false,
          onDrawerChanged: (isOpened) {
            if (!isOpened && controller.isParentUser.value) {
              controller.refreshParentAppBarChild();
            }
          },
          appBar:
              showCustomAppBar
                  ? PreferredSize(
                    preferredSize: const Size.fromHeight(150),
                    child: CustomAppBar(
                      profileUrl: controller.appBarProfileUrl,
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: roleWelcomePrefix,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: AppFontFamily.forText(
                                  roleWelcomePrefix,
                                ),
                              ),
                            ),
                            TextSpan(
                              text:
                                  controller.userName.value.trim().isEmpty
                                      ? dashboardController.displayName
                                      : controller.userName.value,
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: AppColor.yellow,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFontFamily.forText(
                                  controller.userName.value.trim().isEmpty
                                      ? dashboardController.displayName
                                      : controller.userName.value,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: ' !',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: AppFontFamily.forText('!'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subTitle: roleSubTitle,
                      imagePath:
                          controller.bannerUrl.value.isEmpty
                              ? 'assets/images/sliver_banner1.png'
                              : controller.bannerUrl.value,
                    ),
                  )
                  : null,
          drawer: const DrawerWidget(),
          body: Center(child: controller.selectedScreen.value),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15),
              ],
            ),
            child: StyleProvider(
              style: _BottomNavStyle(fontSize: navFontSize),
              child: ConvexAppBar(
                key: const ValueKey<String>('nav-4'),
                backgroundColor: AppColor.white,
                color: AppColor.lightGreen,
                activeColor: AppColor.primary,
                height: 66,
                style: TabStyle.reactCircle,
                initialActiveIndex: selectedIndex,
                onTap: controller.changeMenuIndex,
                shadowColor: const Color.fromARGB(255, 179, 211, 207),
                items: [
                  TabItem(
                    icon: Icons.dashboard,
                    title: LocaleKeys.dashboard.tr,
                  ),
                  TabItem(
                    icon: Icons.notifications,
                    title: LocaleKeys.notification.tr,
                  ),
                  if (!isParent)
                    TabItem(
                      icon: Icons.qr_code_scanner_sharp,
                      title: LocaleKeys.scanner.tr,
                    ),
                  if (isParent)
                    TabItem(
                      icon: Icons.mobile_friendly,
                      title: LocaleKeys.payments.tr,
                    ),
                  TabItem(
                    icon: Icons.contact_phone,
                    title: LocaleKeys.contact.tr,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _BottomNavStyle extends StyleHook {
  _BottomNavStyle({required this.fontSize});

  final double fontSize;

  @override
  double? get iconSize => 22;

  @override
  double get activeIconMargin => 8;

  @override
  double get activeIconSize => 24;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(
      color: color,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.0,
    );
  }
}
