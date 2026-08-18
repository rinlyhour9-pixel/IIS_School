import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/homework/controller.dart';
import 'package:schoolapp/views/homework/widgets/homework_widget.dart';

class HomeworkView extends GetView<HomeworkController> {
  const HomeworkView({super.key});

  @override
  Widget build(BuildContext context) {
    final isParent = controller.isParentRole;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _HomeworkHeader(
              title: LocaleKeys.onlineClassTitle.tr,
              subTitle: LocaleKeys.onlineClassParentSubtitle.tr,
              teacherSubTitle: LocaleKeys.onlineClassTeacherSubtitle.tr,
              showMenu: false,
            ),
          ),
          const Expanded(child: HomeworkWidget()),
        ],
      ),
      bottomNavigationBar:
          isParent
              ? null
              : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                  child: SizedBox(
                    height: 66,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3345), Color(0xFFD80F23)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3BD80F23),
                            blurRadius: 18,
                            offset: Offset(0, 9),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => HomeworkWidget.openAssignHomework(context),
                        icon: const Icon(Icons.add_rounded, size: 30),
                        label: Text(
                          LocaleKeys.onlineClassActionAssignHomework.tr,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}

class _HomeworkHeader extends StatelessWidget {
  const _HomeworkHeader({
    required this.title,
    required this.subTitle,
    required this.teacherSubTitle,
    required this.showMenu,
  });

  final String title;
  final String subTitle;
  final String teacherSubTitle;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final subtitle = showMenu ? subTitle : teacherSubTitle;
    final controller = Get.find<HomeworkController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Stack(
        children: [
          Positioned(
            right: 12,
            top: -27,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/logo_bacground.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _HeaderCircleButton(
                    icon:
                        showMenu
                            ? Icons.menu_rounded
                            : Icons.arrow_back_rounded,
                    onTap:
                        showMenu
                            ? () => Scaffold.maybeOf(context)?.openDrawer()
                            : Navigator.of(context).maybePop,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.largePrimaryBold.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _HeaderCircleButton(
                          icon: Icons.notifications_rounded,
                          onTap: controller.markHomeworkNotificationsSeen,
                        ),
                        if (controller.hasHomeworkNotification.value)
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.smallGreyRegular.copyWith(
                    color: const Color(0xFF6E6E76),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: const Color(0x14000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: const Color(0xFFD80F23), size: 22),
        ),
      ),
    );
  }
}
