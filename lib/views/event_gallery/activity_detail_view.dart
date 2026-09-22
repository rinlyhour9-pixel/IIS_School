import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/event_gallery/activity_create_view.dart';
import 'package:schoolapp/views/event_gallery/controller.dart';

class ActivityDetailView extends StatefulWidget {
  const ActivityDetailView({super.key, required this.detail, this.summary});

  final ClassActivityDetailItem detail;
  final ClassActivityItem? summary;

  @override
  State<ActivityDetailView> createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  late ClassActivityDetailItem _detail;
  ClassActivityItem? _summary;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _detail = widget.detail;
    _summary = widget.summary;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActivityController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(LocaleKeys.activity.tr, style: const TextStyle()),
        centerTitle: true,
        backgroundColor: const Color(0xFF153D6F),
        foregroundColor: Colors.white,
      ),
      floatingActionButton:
          !UserRepository.shared.isParent && _summary != null
              ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'edit_activity_${_summary!.id}',
                    onPressed: () => _openEdit(controller),
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.edit_rounded),
                    label: Text(LocaleKeys.editActivity.tr),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => FloatingActionButton.extended(
                      heroTag: 'delete_activity_${_summary!.id}',
                      onPressed:
                          controller.isSubmittingActivity.value
                              ? null
                              : () => _confirmDelete(context, controller),
                      backgroundColor: const Color(0xFFD14343),
                      foregroundColor: Colors.white,
                      icon:
                          controller.isSubmittingActivity.value
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.delete_rounded),
                      label: Text(
                        controller.isSubmittingActivity.value
                            ? LocaleKeys.deleting.tr
                            : LocaleKeys.deleteActivity.tr,
                      ),
                    ),
                  ),
                ],
              )
              : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  _detailImages(_detail.images),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xB3153D6F),
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                              _summary?.className.trim().isNotEmpty == true
                                  ? _summary!.className
                                  : LocaleKeys.classActivity.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _detail.title,
                            style: const TextStyle(
                              fontSize: 20,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE4E9E7)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12111827),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.activityDetails.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF153D6F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocaleKeys.activityDetailsSubtitle.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FBFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4E9E7)),
                    ),
                    child: Text(
                      _stripHtml(_detail.description).isEmpty
                          ? LocaleKeys.noDescriptionProvided.tr
                          : _stripHtml(_detail.description),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailImages(List<String> images) {
    if (images.length <= 1) {
      return ResolvedNetworkImage(
        rawPath: images.isEmpty ? '' : images.first,
        width: double.infinity,
        height: 300,
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            // Only safe to enable with more than one item — with exactly
            // one, carousel_slider still builds a looping PageView, which
            // can drag to a blank page and desyncs the dot indicator.
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            autoPlayCurve: Curves.easeInOut,
            // Let a manual swipe interrupt the slideshow instead of fighting
            // it — pauses briefly, then resumes auto-advancing.
            pauseAutoPlayOnTouch: true,
            onPageChanged:
                (index, _) => setState(() => _currentImageIndex = index),
          ),
          items:
              images
                  .map(
                    (url) => ResolvedNetworkImage(
                      rawPath: url,
                      width: double.infinity,
                      height: 300,
                    ),
                  )
                  .toList(),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x66000000),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(images.length, (index) {
                final isActive = index == _currentImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: EdgeInsets.only(
                    right: index == images.length - 1 ? 0 : 5,
                  ),
                  width: isActive ? 14 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        isActive ? Colors.white : Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ActivityController controller,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: Text(LocaleKeys.deleteActivity.tr),
                content: Text(LocaleKeys.confirmDeleteMessage.tr),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(LocaleKeys.cancel.tr),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(
                      LocaleKeys.delete.tr,
                      style: const TextStyle(color: Color(0xFFD14343)),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmed || _summary == null) {
      return;
    }

    try {
      await controller.deleteActivity(_summary!.id);
      if (!context.mounted) return;
      Get.back();
      final snackbarTitle = LocaleKeys.success.tr;
      final snackbarMessage = LocaleKeys.activityDeletedSuccess.tr;
      Get.snackbar(
        snackbarTitle,
        snackbarMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF14925A),
        titleText: Text(
          snackbarTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: AppFontFamily.forText(snackbarTitle),
          ),
        ),
        messageText: Text(
          snackbarMessage,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: AppFontFamily.forText(snackbarMessage),
          ),
        ),
      );
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> _openEdit(ActivityController controller) async {
    final summary = _summary;
    if (summary == null) return;

    final updated =
        await Get.to<bool>(
          () => TeacherCreateActivityView(initialActivity: summary),
        ) ??
        false;
    if (!updated || !mounted) {
      return;
    }

    final refreshedDetail = await controller.fetchClassActivityDetail(
      summary.id,
    );
    if (!mounted || refreshedDetail == null) {
      return;
    }

    final refreshedSummary = controller.activities.firstWhereOrNull(
      (item) => item.id == summary.id,
    );
    setState(() {
      _detail = refreshedDetail;
      _summary = refreshedSummary ?? _summary;
    });
  }
}
