import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:schoolapp/views/request_leave/controller.dart';

class StudentCard1Widget extends StatelessWidget {
  const StudentCard1Widget({super.key});

  static const _fieldRadius = 12.0;
  static const _cardRadius = 20.0;
  static const _sectionCardColor = Color(0xFFF3F3F4);
  static final Color _outlineRed = AppColor.primary.withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestLeaveController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: _outlineRed, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// STUDENT INFO
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Obx(
                              () => _studentImage(
                                controller.studentImageUrl.value,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => Text(
                              controller.studentNameText.value.isEmpty
                                  ? '-'
                                  : controller.studentNameText.value,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.smallPrimaryBoldBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _iconLabel(
                            Icons.person_outline,
                            LocaleKeys.studentId.tr,
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => _buildInput(
                              controller.studentIdText.value.isEmpty
                                  ? '-'
                                  : controller.studentIdText.value,
                              trailingIcon: Icons.copy_outlined,
                              onTrailingTap:
                                  () => _copyStudentId(
                                    controller.studentIdText.value,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE6E6E6)),
                const SizedBox(height: 16),

                _fieldRow(
                  icon: Icons.school_outlined,
                  label: LocaleKeys.classLabel.tr,
                  field: _buildClassDropdown(controller),
                ),
                const SizedBox(height: 12),
                _fieldRow(
                  icon: Icons.layers_outlined,
                  label: LocaleKeys.section.tr,
                  field: Obx(
                    () => _readOnlySection(
                      controller.selectedSection.value.isEmpty
                          ? '-'
                          : controller.selectedSection.value,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE6E6E6)),
                const SizedBox(height: 20),

                /// LEAVE DETAILS
                Row(
                  children: [
                    Expanded(
                      child: _iconLabel(
                        Icons.calendar_today_outlined,
                        LocaleKeys.leaveFromDate.tr,
                        style: AppTextStyle.smallPrimaryBoldBlack,
                        badgeSize: 22,
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: _iconLabel(
                        Icons.calendar_today_outlined,
                        LocaleKeys.leaveToDate.tr,
                        style: AppTextStyle.smallPrimaryBoldBlack,
                        badgeSize: 22,
                      ),
                    ),
                  ],
                ),
                8.height,
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _dateBox(
                          controller.startDate.value,
                          onTap: controller.pickStartDate,
                        ),
                      ),
                    ),
                    8.width,
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColor.primary,
                    ),
                    8.width,
                    Expanded(
                      child: Obx(
                        () => _dateBox(
                          controller.endDate.value,
                          onTap: controller.pickEndDate,
                        ),
                      ),
                    ),
                  ],
                ),
                12.height,
                Obx(
                  () => Row(
                    children: [
                      _iconLabel(
                        Icons.calendar_month_outlined,
                        '${LocaleKeys.totalLeaveDays.tr}:',
                        style: AppTextStyle.smallPrimaryBoldBlack,
                        badgeSize: 22,
                      ),
                      8.width,
                      Container(
                        width: 56,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FCEA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _outlineRed),
                        ),
                        child: Text(
                          controller.totalDays == 0
                              ? '-'
                              : controller.totalDays.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                14.height,
                Text(
                  '${LocaleKeys.leaveReason.tr}:',
                  style: AppTextStyle.smallPrimaryBoldBlack,
                ),
                6.height,
                Obx(
                  () => TextFormField(
                    controller: controller.reasonController,
                    style: AppTextStyle.smallPrimaryBoldBlack,
                    maxLines: 5,
                    maxLength: 300,
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) {
                        controller.reasonError.value = '';
                      }
                    },
                    decoration: InputDecoration(
                      hintText: LocaleKeys.otherReasonHint.tr,
                      prefixIcon: const Icon(
                        Icons.edit_outlined,
                        color: AppColor.primary,
                        size: 18,
                      ),
                      errorText:
                          controller.reasonError.value.isEmpty
                              ? null
                              : controller.reasonError.value,
                      counterStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_fieldRadius),
                        borderSide: BorderSide(color: _outlineRed),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_fieldRadius),
                        borderSide: BorderSide(color: _outlineRed, width: 1.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_fieldRadius),
                        borderSide: BorderSide(color: _outlineRed),
                      ),
                    ),
                  ),
                ),

                UIConstants.spacing.height,

                /// SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed:
                          controller.isloading.value
                              ? null
                              : () async {
                                final created =
                                    await controller.submitRequest();
                                if (created != null) {
                                  Get.back(result: created);
                                }
                              },
                      child:
                          controller.isloading.value
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                LocaleKeys.send.tr,
                                style: AppTextStyle.mediumWhiteSemiBold,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon(
              //   Icons.shield_outlined,
              //   size: 14,
              //   color: Colors.grey.shade500,
              // ),
              6.width,
              Flexible(
                child: Text(
                  LocaleKeys.leaveRequestReviewNote.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String text, {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_fieldRadius),
            border: Border.all(color: _outlineRed),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  text.isEmpty ? LocaleKeys.selectDate.tr : text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: text.isEmpty ? Colors.grey : AppColor.black,
                  ),
                ),
              ),
              6.width,
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColor.primary,
                size: 15,
              ),
            ],
          ),
        ),
      );

  Widget _buildInput(
    String text, {
    IconData? trailingIcon,
    VoidCallback? onTrailingTap,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: _outlineRed),
      borderRadius: BorderRadius.circular(_fieldRadius),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(text)),
        if (trailingIcon != null) ...[
          8.width,
          GestureDetector(
            onTap: onTrailingTap,
            child: Icon(trailingIcon, color: AppColor.primary, size: 18),
          ),
        ],
      ],
    ),
  );

  void _copyStudentId(String value) {
    if (value.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    Get.snackbar(
      LocaleKeys.studentIdCopied.tr,
      value,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _fieldRow({
    required IconData icon,
    required String label,
    required Widget field,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(width: 110, child: _iconLabel(icon, label)),
      8.width,
      Expanded(child: field),
    ],
  );

  Widget _buildClassDropdown(RequestLeaveController controller) => Obx(
    () => AppIconDropdown<String>(
      value: controller.selectedClasses.firstOrNull,
      items: controller.classOptions.toList(growable: false),
      itemLabel: (c) => c,
      hintText: LocaleKeys.classLabel.tr,
      onChanged: (picked) {
        if (picked == null) return;
        controller.setSelectedClasses(<String>[picked]);
      },
    ),
  );

  Widget _readOnlySection(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: _sectionCardColor,
      borderRadius: BorderRadius.circular(_fieldRadius),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            text,
            style: AppTextStyle.smallPrimaryBoldBlack.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        8.width,
        // Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400),
      ],
    ),
  );

  Widget _iconLabel(
    IconData icon,
    String label, {
    TextStyle? style,
    double badgeSize = 26,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: badgeSize,
        height: badgeSize,
        child: Icon(icon, size: badgeSize * 0.72, color: AppColor.primary),
      ),
      6.width,
      Flexible(
        child: Text(
          label,
          style: style ?? AppTextStyle.regularPrimaryBoldblack,
        ),
      ),
    ],
  );

  Widget _studentImage(String rawUrl) {
    final candidates = _resolveImageUrlCandidates(rawUrl);
    if (candidates.isEmpty) {
      return const Icon(Icons.person, color: Colors.grey);
    }
    final first = candidates.first;
    if (first.startsWith('assets/')) {
      return Image.asset(first, fit: BoxFit.cover);
    }
    return _studentImageNetwork(candidates, 0);
  }

  Widget _studentImageNetwork(List<String> urls, int index) {
    if (index >= urls.length) {
      return const Icon(Icons.person, color: Colors.grey);
    }
    return CachedNetworkImage(
      imageUrl: urls[index],
      fit: BoxFit.cover,
      width: 90,
      height: 100,
      memCacheWidth: 180,
      memCacheHeight: 200,
      maxWidthDiskCache: 180,
      maxHeightDiskCache: 200,
      httpHeaders: _imageHeaders() ?? const <String, String>{},
      useOldImageOnUrlChange: true,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder:
          (_, __) => Container(
            color: const Color(0xFFF1F5F9),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: Color(0xFF6B7280)),
          ),
      errorWidget: (_, __, ___) => _studentImageNetwork(urls, index + 1),
    );
  }

  Map<String, String>? _imageHeaders() {
    final token = AppConfig.shared.authorizationToken.trim();
    if (token.isEmpty) {
      return null;
    }
    return <String, String>{'Authorization': token, 'Accept': 'image/*'};
  }

  List<String> _resolveImageUrlCandidates(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) {
      return const <String>[];
    }

    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return _networkUrlVariants(value);
    }
    if (value.startsWith('assets/')) {
      return <String>[value];
    }

    final base = AppConfig.shared.baseUrl.trim();
    if (base.isEmpty) {
      return const <String>[];
    }
    final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    final path = value.replaceAll('\\', '/');
    final raw = path.startsWith('/') ? path.substring(1) : path;
    final candidates = <String>[
      raw,
      if (!raw.startsWith('uploads/')) 'uploads/$raw',
      if (!raw.startsWith('storage/')) 'storage/$raw',
      if (!raw.startsWith('public/')) 'public/$raw',
      raw.replaceFirst('uploads/uploads/', 'uploads/'),
    ];
    final seen = <String>{};
    final resolved = <String>[];
    for (final c in candidates) {
      final url = baseUri.resolve(c).toString();
      if (seen.add(url)) {
        resolved.add(url);
      }
    }
    return resolved;
  }

  List<String> _networkUrlVariants(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return <String>[url];
    }
    final path = uri.path.replaceAll('\\', '/');
    final fixedUploads = path.replaceFirst('/uploads/uploads/', '/uploads/');
    final deduped = _dedupePath(path);
    final variants = <String>[
      uri.replace(path: fixedUploads).toString(),
      uri.replace(path: deduped).toString(),
      url,
    ];
    final seen = <String>{};
    return variants.where((v) => seen.add(v)).toList();
  }

  String _dedupePath(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final compact = <String>[];
    for (final p in parts) {
      if (compact.isEmpty || compact.last.toLowerCase() != p.toLowerCase()) {
        compact.add(p);
      }
    }
    return '/${compact.join('/')}';
  }
}
