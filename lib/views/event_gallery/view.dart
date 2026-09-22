import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/event_gallery/activity_create_view.dart';
import 'package:schoolapp/views/event_gallery/activity_detail_view.dart';
import 'package:schoolapp/views/event_gallery/controller.dart';
import 'package:schoolapp/views/event_gallery/widgets/eventgallery_card.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';
import 'package:schoolapp/views/start/widgets/customize_app_bar.dart';

class ActivityView extends GetView<ActivityController> {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Obx(() {
          final activities = controller.activities.toList(growable: false);
          final isLoading = controller.isLoading.value;
          final isLoadingMore = controller.isLoadingMore.value;
          final isDetailLoading = controller.isDetailLoading.value;
          final hasMorePages = controller.hasMorePages;
          final topImage = activities.isNotEmpty ? activities.first.image : '';
          final isTeacher = controller.isTeacherRole;
          // Students switch classes (the endpoint is per-class, so this
          // re-fetches). Teachers keep the read-only badges derived from
          // whatever activities happen to be loaded.
          final studentClassOptions =
              controller.studentClassOptions.toList(growable: false);
          final selectedStudentClassId = controller.selectedStudentClassId.value;
          final classNames =
              activities
                  .map((item) => item.className.trim())
                  .where((name) => name.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
          final showStudentClassChips =
              !isTeacher && studentClassOptions.length > 1;
          final showTeacherClassChips = isTeacher && classNames.isNotEmpty;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: controller.fetchClassActivities,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomizeAppBar(
                        title: LocaleKeys.activity.tr,
                        subTitle: LocaleKeys.activitySubTitle.tr,
                        teacherSubTitle: LocaleKeys.activityTeacherSubTitle.tr,
                      ),
                      UIConstants.spacingSmall.height,
                      const CustomIndicator(progress: 1 / 4),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            ResolvedNetworkImage(
                              rawPath: topImage,
                              height: 190,
                              width: double.infinity,
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF153D6F).withValues(alpha: 0.84),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x26FFFFFF),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      controller.isTeacherRole
                                          ? LocaleKeys.teacherActivityFeed.tr
                                          : LocaleKeys.studentActivityFeed.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(height: 10),
                                  // Text(
                                  //   controller.isTeacherRole
                                  //       ? 'Track the latest class moments, updates, and posts from every class you teach.'
                                  //       : 'See the latest activities prepared for your selected class.',
                                  //   style: const TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 18,
                                  //     fontWeight: FontWeight.w800,
                                  //     height: 1.3,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (showStudentClassChips)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final option in studentClassOptions)
                              ClassChip(
                                label: option.name,
                                selected: option.id == selectedStudentClassId,
                                onTap:
                                    () => controller.selectStudentClass(
                                      option.id,
                                    ),
                              ),
                          ],
                        )
                      else if (showTeacherClassChips)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final className in classNames)
                              ClassChip(label: className),
                          ],
                        ),
                      if (showStudentClassChips || showTeacherClassChips)
                        const SizedBox(height: 16),
                      if (isLoading && activities.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(
                              color: AppColor.primary,
                            ),
                          ),
                        )
                      else if (activities.isEmpty)
                        const _EmptyActivityState()
                      else
                        Column(
                          children: [
                            if (isLoading)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: LinearProgressIndicator(
                                  minHeight: 3,
                                  color: AppColor.primary,
                                  backgroundColor: Color(0xFFD9E6E2),
                                ),
                              ),
                            ActivityCardWidget(
                              items: activities,
                              onTap: (item) async {
                                final detail = await controller
                                    .fetchClassActivityDetail(item.id);
                                if (detail == null) return;
                                Get.to(
                                  () => ActivityDetailView(
                                    detail: detail,
                                    summary: item,
                                  ),
                                );
                              },
                            ),
                            if (hasMorePages || isLoadingMore) ...[
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child:
                                    isLoadingMore
                                        ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: CircularProgressIndicator(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        )
                                        : OutlinedButton.icon(
                                          onPressed:
                                              controller.loadMoreActivities,
                                          icon: const Icon(
                                            Icons.expand_more_rounded,
                                          ),
                                          label: Text(
                                            'Load more (${controller.currentPage.value}/${controller.lastPage.value})',
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              48,
                                            ),
                                            foregroundColor: AppColor.primary,
                                            side: const BorderSide(
                                              color: Color(0xFFCCE0DA),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              if (isDetailLoading)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColor.white),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
      bottomNavigationBar:
          controller.isTeacherRole
              ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF153D6F), Color(0xFF0D5C4F)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22153D6F),
                          blurRadius: 16,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: () => _openCreateActivity(context),
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: Text(LocaleKeys.createActivity.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              : null,
    );
  }

  void _openCreateActivity(BuildContext context) {
    Get.to(() => const TeacherCreateActivityView());
  }

}

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E9E7)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 40,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.noClassActivitiesFound.tr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
