import 'package:schoolapp/views/views.dart';
import 'package:schoolapp/views/leaves/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import '../start/widgets/customize_app_bar.dart';

class LeavesView extends GetView<LeavesController> {
  const LeavesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomizeAppBar(
              title: LocaleKeys.leavesTitle.tr,
              subTitle: LocaleKeys.leavesSubTitle.tr,
              teacherSubTitle: LocaleKeys.leavesTeacherSubTitle.tr,
              trailing: const _AppBarDateFilter(),
            ),
          ),
          UIConstants.spacingSmall.height,
          const _StatusTabs(),
          UIConstants.spacingSmall.height,
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.leaveList.isEmpty) {
                return Center(
                  child: Text(
                    LocaleKeys.noDataFound.tr,
                    style: AppTextStyle.normalGreyRegular,
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadLeaves,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: controller.leaveList.length,
                  itemBuilder: (context, index) {
                    final item = controller.leaveList[index];
                    return LeaveCardWidget(
                      item: item,
                      onView: () async {
                        await controller.viewLeaveDetail(item.id);
                        if (context.mounted) {
                          showLeaveDetailSheet(context, controller);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AppBarDateFilter extends GetView<LeavesController> {
  const _AppBarDateFilter();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasDate =
          controller.fromDate.value.isNotEmpty ||
          controller.toDate.value.isNotEmpty;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDate)
            IconButton(
              onPressed: controller.clearDateFilter,
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Clear date',
            ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => showLeaveDateFilterSheet(context, controller),
                icon: const Icon(Icons.calendar_today_outlined, size: 20),
                tooltip: 'Filter by date',
              ),
              if (hasDate)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}

class _StatusTabs extends GetView<LeavesController> {
  const _StatusTabs();

  static const _tabs = [
    {'labelKey': LocaleKeys.all, 'value': ''},
    {'labelKey': LocaleKeys.pending, 'value': 'pending'},
    {'labelKey': LocaleKeys.approved, 'value': 'approved'},
    {'labelKey': LocaleKeys.rejected, 'value': 'rejected'},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children:
                _tabs.map((tab) {
                  final isSelected =
                      controller.selectedStatus.value == tab['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setStatusFilter(tab['value']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColor.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab['labelKey']!.tr,
                          textAlign: TextAlign.center,
                          style:
                              isSelected
                                  ? AppTextStyle.smallWhiteSemibold
                                  : AppTextStyle.normalPrimarySemiBold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    });
  }
}
