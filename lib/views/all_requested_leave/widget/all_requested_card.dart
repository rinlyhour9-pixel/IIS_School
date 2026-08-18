import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/requestleave/model.dart';
import 'package:schoolapp/views/all_requested_leave/widget/all_requested_leave_item_card.dart';
import 'package:schoolapp/views/all_requested_leave/widget/all_requested_leave_status.dart';
import 'package:schoolapp/views/all_requested_leave/widget/custom_tab.dart';
import 'package:schoolapp/views/request_leave/controller.dart';
import 'package:schoolapp/views/request_leave/view.dart';

class AllRequestedCard extends StatefulWidget {
  const AllRequestedCard({super.key});

  @override
  State<AllRequestedCard> createState() => _AllRequestedCardState();
}

class _AllRequestedCardState extends State<AllRequestedCard> {
  int selectedIndex = 0;
  int _tabMotion = 1;
  final controller =
      Get.isRegistered<RequestLeaveController>()
          ? Get.find<RequestLeaveController>()
          : Get.put(RequestLeaveController());

  @override
  void initState() {
    super.initState();
    controller.fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() < 120) {
              return;
            }
            if (velocity < 0) {
              _changeTab(selectedIndex + 1);
            } else {
              _changeTab(selectedIndex - 1);
            }
          },
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: CustomTopTabBar(
                    selectedIndex: selectedIndex,
                    onChanged: _changeTab,
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingRequests.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<RequestLeaveModel> list = [];

                    if (selectedIndex == 0) {
                      list = controller.requests.toList();
                    } else if (selectedIndex == 1) {
                      list =
                          controller.requests
                              .where(
                                (e) => requestLeaveStatusOf(e) == 'pending',
                              )
                              .toList();
                    } else if (selectedIndex == 2) {
                      list =
                          controller.requests
                              .where(
                                (e) => requestLeaveStatusOf(e) == 'approved',
                              )
                              .toList();
                    } else {
                      list =
                          controller.requests
                              .where(
                                (e) => requestLeaveStatusOf(e) == 'rejected',
                              )
                              .toList();
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final beginX = _tabMotion > 0 ? 0.08 : -0.08;
                        final offset = Tween<Offset>(
                          begin: Offset(beginX, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offset,
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(selectedIndex),
                        child: RefreshIndicator(
                          onRefresh: controller.fetchRequests,
                          child:
                              list.isEmpty
                                  ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 120),
                                    children: [
                                      Center(child: Text(LocaleKeys.noData.tr)),
                                    ],
                                  )
                                  : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(10),
                                    itemCount: list.length,
                                    itemBuilder:
                                        (context, index) =>
                                            AllRequestedLeaveItemCard(
                                              item: list[index],
                                              selectedStudentName:
                                                  controller
                                                      .studentNameText
                                                      .value
                                                      .trim(),
                                              selectedStudentGrade:
                                                  controller
                                                      .studentGradeText
                                                      .value
                                                      .trim(),
                                            ),
                                  ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF0F6B5B),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onPressed: () async {
              final result = await Get.to(() => const RequestLeaveView());
              if (!mounted) {
                return;
              }
              if (result is RequestLeaveModel) {
                if (!_hasSameRequest(result)) {
                  controller.requests.insert(0, result);
                }
                setState(() => selectedIndex = 1);
                return;
              }
              if (result == 'pending') {
                setState(() => selectedIndex = 1);
                return;
              }
              await controller.fetchRequests();
            },
            label: Text(
              LocaleKeys.requestLeaveTitle.tr,
              style: const TextStyle(color: Colors.white),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  bool _hasSameRequest(RequestLeaveModel target) {
    for (final item in controller.requests) {
      final itemStudent = (item.studentId ?? '').trim();
      final targetStudent = (target.studentId ?? '').trim();
      final sameStudent =
          itemStudent.isEmpty ||
          targetStudent.isEmpty ||
          itemStudent == targetStudent;
      final sameDate =
          (item.dateStart ?? '') == (target.dateStart ?? '') &&
          (item.dateEnd ?? '') == (target.dateEnd ?? '');
      final sameReason =
          (item.reason ?? '').trim() == (target.reason ?? '').trim();
      final sameStatus =
          requestLeaveStatusOf(item) == requestLeaveStatusOf(target);
      if (sameStudent && sameDate && sameReason && sameStatus) {
        return true;
      }
    }
    return false;
  }

  void _changeTab(int index) {
    final next = index.clamp(0, 3).toInt();
    if (next == selectedIndex) {
      return;
    }
    setState(() {
      _tabMotion = next > selectedIndex ? 1 : -1;
      selectedIndex = next;
    });
  }
}
