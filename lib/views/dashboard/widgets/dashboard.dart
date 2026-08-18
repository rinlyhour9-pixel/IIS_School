import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/routes.dart';
import 'package:schoolapp/views/dashboard/controller.dart';
import 'package:schoolapp/views/dashboard/widgets/dashboard_slider_section.dart';
import 'package:schoolapp/views/start/controller.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  List<String> get _catName => [
    LocaleKeys.dashboardMenuTuitionFee.tr,
    LocaleKeys.dashboardMenuAttendance.tr,
    LocaleKeys.dashboardMenuRequestLeave.tr,
    LocaleKeys.dashboardMenuSchedule.tr,
    LocaleKeys.dashboardMenuStandings.tr,
    LocaleKeys.dashboardMenuAttendanceLog.tr,
    LocaleKeys.dashboardMenuStudentReport.tr,
    LocaleKeys.dashboardMenuClassActivity.tr,
    LocaleKeys.dashboardMenuOnlineCourse.tr,
    LocaleKeys.dashboardMenuLeaves.tr,
    LocaleKeys.dashboardMenuStudentAttendance.tr,
  ];

  final List<String> catIconPaths = [
    'assets/images/icon/payment.png',
    'assets/images/icon/attendance.png',
    'assets/images/icon/attendance_leave.png',
    'assets/images/icon/time_table.png',
    'assets/images/icon/score.png',
    'assets/images/icon/list_attendance.png',
    'assets/images/icon/student_report.png',
    'assets/images/icon/class_activity.png',
    'assets/images/icon/online_course.png',
    'assets/images/icon/leaves.png',
    'assets/images/icon/student_attendance.png',
  ];

  final Color _panelColor = const Color(0xFFFFFFFF);
  final Color _iconBgColor = const Color(0xFFFFFFFF);

  DashboardController controller = Get.find<DashboardController>();
  StartController? get _startController =>
      Get.isRegistered<StartController>() ? Get.find<StartController>() : null;

  bool _isParentRole() {
    final startCtl = _startController;
    final result =
        startCtl != null
            ? startCtl.isParentUser.value
            : UserRepository.shared.isParent;
    return result;
  }

  List<int> _visibleMenuIndices() {
    final isParent = _isParentRole();
    if (isParent) {
      return const [0, 1, 2, 3, 4, 5, 6, 7, 8];
    }
    return const [3, 7, 8, 9, 10];
  }

  void click(int index) {
    final isParent = _isParentRole();
    if ((!isParent && (index == 2 || index == 4)) ||
        (isParent && (index == 4 || index == 6))) {
      _showUnavailableDialog(_catName[index]);
      return;
    }

    switch (index) {
      case 0:
        Get.toNamed(Routes.paymentHistory);
        break;
      case 1:
        Get.toNamed(Routes.attendance);
        break;
      case 2:
        Get.toNamed(Routes.allRequestLeave);

        break;
      case 3:
        Get.toNamed(Routes.schedule);

        break;
      case 4:
        Get.toNamed(Routes.standings);
        break;
      case 5:
        Get.toNamed(Routes.attendanceRecord);
        break;
      case 6:
        Get.toNamed(Routes.studentDocument);
        break;
      case 7:
        Get.toNamed(Routes.activity);
        break;
      case 8:
        Get.toNamed(Routes.homework);
        break;
      case 9:
        Get.toNamed(Routes.leaves);
        break;
      case 10:
        Get.toNamed(Routes.studentAttendance);
        break;
    }
  }

  void _showUnavailableDialog(String featureName) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFE7EEED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                color: AppColor.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              featureName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.featureTemporarilyUnavailable.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: Get.back,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                LocaleKeys.ok.tr,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _startController?.isParentUser.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          final visibleMenuIndices = _visibleMenuIndices();
          final visibleCount = visibleMenuIndices.length;
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final bottomNavOverlay = MediaQuery.of(context).padding.bottom + 84.0;
          final usableHeight = (height - bottomNavOverlay).clamp(420.0, 2000.0);
          final crossAxisCount =
              width >= 900
                  ? 5
                  : width >= 700
                  ? 4
                  : 3;

          final rows = (visibleCount / crossAxisCount).ceil();

          final sliderHeight =
              usableHeight < 620
                  ? 156.0
                  : width >= 700
                  ? 224.0
                  : 186.0;
          const topGap = 10.0;
          const middleGap = 8.0;
          const bottomPadding = 10.0;
          final horizontalPadding = width >= 700 ? 20.0 : 12.0;
          final crossSpacing = width >= 700 ? 16.0 : 12.0;
          final mainSpacing = width >= 700 ? 16.0 : 12.0;
          const gridTopPadding = 4.0;
          const gridBottomPadding = 16.0;
          final gridBottomInset = gridBottomPadding + bottomNavOverlay;
          final gridPaddingVertical = gridTopPadding + gridBottomInset;
          final spacingTotal = (rows - 1) * mainSpacing;
          final remaining =
              usableHeight -
              sliderHeight -
              topGap -
              middleGap -
              bottomPadding -
              gridPaddingVertical -
              spacingTotal;
          final tileHeight = (remaining / rows).clamp(98.0, 165.0);
          final gridContentHeight =
              (rows * tileHeight) + spacingTotal + gridPaddingVertical;
          final availableGridHeight =
              usableHeight - sliderHeight - topGap - middleGap - bottomPadding;
          final shouldScrollGrid = gridContentHeight > availableGridHeight;
          final iconSize = (tileHeight * 0.42).clamp(48.0, 62.0);
          final labelFontSize = (tileHeight * 0.108).clamp(12.0, 15.0);

          return Column(
            children: [
              const SizedBox(height: topGap),
              DashboardSliderSection(height: sliderHeight),
              const SizedBox(height: middleGap),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: _panelColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics:
                        shouldScrollGrid
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      gridTopPadding,
                      horizontalPadding,
                      gridBottomInset,
                    ),
                    itemCount: visibleCount,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisExtent: tileHeight,
                      crossAxisSpacing: crossSpacing,
                      mainAxisSpacing: mainSpacing,
                    ),
                    itemBuilder: (context, index) {
                      final itemIndex = visibleMenuIndices[index];
                      return InkWell(
                        onTap: () => click(itemIndex),
                        borderRadius: BorderRadius.circular(12),
                        child: LayoutBuilder(
                          builder: (context, itemConstraints) {
                            final itemHeight = itemConstraints.maxHeight;
                            final itemIconSize = (itemHeight * 0.62).clamp(
                              66.0,
                              iconSize + 22,
                            );
                            final itemGap = (itemHeight * 0.06).clamp(4.0, 8.0);
                            final itemFontSize = (itemHeight * 0.108).clamp(
                              12.0,
                              labelFontSize,
                            );

                            final isTeacherView = !_isParentRole();
                            final menuLabel =
                                isTeacherView && itemIndex == 5
                                    ? LocaleKeys
                                        .dashboardMenuAttendanceLogTeacher
                                        .tr
                                    : _catName[itemIndex];

                            return Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: itemIconSize,
                                      width: itemIconSize,
                                      decoration: BoxDecoration(
                                        color: _iconBgColor,
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x14000000),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: _menuIcon(
                                          catIconPaths[itemIndex],
                                          (itemIconSize * 0.52).clamp(
                                            34.0,
                                            42.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (itemIndex == 8)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD80F23),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: itemGap),
                                Expanded(
                                  child: Text(
                                    menuLabel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: itemFontSize,
                                      height: 1.15,
                                      color: const Color(0xFF1F2A37),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _menuIcon(String path, double size) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      cacheWidth: 128,
      cacheHeight: 128,
      errorBuilder:
          (_, __, ___) => const Icon(
            Icons.apps_rounded,
            size: 30,
            color: Color(0xFF0B5A57),
          ),
    );
  }
}
