import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/views.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.isRegistered<NotificationController>()
            ? Get.find<NotificationController>()
            : Get.put(NotificationController());

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.notification.tr)),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                12.height,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(LocaleKeys.notification.tr),
                ),
                12.height,
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refreshNotifications,
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.announcements.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.announcements.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: UIConstants.spacing.toDouble(),
                            right: UIConstants.spacing.toDouble(),
                            top: 2,
                            bottom: UIConstants.midSpacing.toDouble(),
                          ),
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No announcements yet.')),
                          ],
                        );
                      }

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: UIConstants.spacing.toDouble(),
                          right: UIConstants.spacing.toDouble(),
                          top: 2,
                          bottom: UIConstants.midSpacing.toDouble(),
                        ),
                        children: [
                          ...List.generate(controller.announcements.length, (
                            index,
                          ) {
                            final item = controller.announcements[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    index ==
                                                controller
                                                        .announcements
                                                        .length -
                                                    1 &&
                                            !controller.hasMorePages &&
                                            !controller.isLoadingMore.value
                                        ? 0
                                        : 10,
                              ),
                              child: NotificationItemWidget(
                                title: item.title,
                                imageUrl: item.image,
                                dateText: 'Announcement',
                                timeText: item.dateText,
                                onTap: () async {
                                  final detail = await controller
                                      .fetchAnnouncementDetail(item.id);
                                  if (detail == null) return;
                                  Get.to(
                                    () =>
                                        AnnouncementDetailView(detail: detail),
                                  );
                                },
                              ),
                            );
                          }),
                          if (controller.hasMorePages ||
                              controller.isLoadingMore.value) ...[
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  controller.isLoadingMore.value
                                      ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                      : OutlinedButton(
                                        onPressed:
                                            controller.loadMoreAnnouncements,
                                        child: Text(
                                          'Load more (${controller.currentPage.value}/${controller.lastPage.value})',
                                        ),
                                      ),
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
            Obx(() {
              if (!controller.isDetailLoading.value) {
                return const SizedBox.shrink();
              }
              return const Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Color(0x22000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AnnouncementDetailView extends StatelessWidget {
  const AnnouncementDetailView({super.key, required this.detail});

  final AnnouncementDetailItem detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(title: Text(LocaleKeys.notification.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detail.image.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomNetworkImage(
                  imageUrl: detail.image,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            if (detail.image.trim().isNotEmpty) const SizedBox(height: 12),
            Text(
              detail.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _stripHtml(detail.description),
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
