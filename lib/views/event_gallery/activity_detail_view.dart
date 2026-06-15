import 'package:cached_network_image/cached_network_image.dart';
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
                    label: const Text('Edit Activity'),
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
                            ? 'Deleting...'
                            : 'Delete Activity',
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
                  _detailImage(_detail.image),
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
                                  : 'Class Activity',
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
                  const Text(
                    'Activity Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF153D6F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Everything students should know before opening or responding to this class activity.',
                    style: TextStyle(
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
                          ? 'No description was provided for this activity.'
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

  Widget _detailImage(String imagePath) {
    final normalizedPath = imagePath.trim();
    if (normalizedPath.isEmpty) {
      return Image.asset(
        'assets/images/placeholder.png',
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    }

    if (normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: normalizedPath,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFFE9EEF2)),
        errorWidget:
            (_, __, ___) => Image.asset(
              'assets/images/placeholder.png',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
      );
    }

    return Image.asset(
      normalizedPath,
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder:
          (_, __, ___) => Image.asset(
            'assets/images/placeholder.png',
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
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
                title: const Text('Delete Activity'),
                content: const Text(
                  'Are you sure you want to delete this activity?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFD14343)),
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
      const snackbarTitle = 'Success';
      const snackbarMessage = 'Activity deleted successfully';
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
