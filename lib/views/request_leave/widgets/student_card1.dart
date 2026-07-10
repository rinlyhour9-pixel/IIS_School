import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:schoolapp/views/request_leave/controller.dart';

class StudentCard1Widget extends StatelessWidget {
  const StudentCard1Widget({super.key});

  static const _fieldRadius = 12.0;
  static const _cardRadius = 20.0;
  static const _sectionCardColor = Color(0xFFF3F3F4);
  static const _leaveDaysColor = Color(0xFFFCEAE8);
  static final Color _outlineRed = AppColor.red.withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestLeaveController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// SECTION 1: STUDENT INFO
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              LocaleKeys.requestLeaveSelectStudent.tr,
              style: AppTextStyle.mediumPrimaryBoldText.copyWith(
                color: AppColor.black,
              ),
              softWrap: true,
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _sectionCardColor,
              borderRadius: BorderRadius.circular(_cardRadius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
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
                        () => _studentImage(controller.studentImageUrl.value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.studentNameText.value.isEmpty
                            ? LocaleKeys.student.tr
                            : controller.studentNameText.value,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.regularPrimaryBoldblack,
                      ),
                    ),
                    Text(
                      LocaleKeys.student.tr,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.studentId.tr,
                        style: AppTextStyle.regularPrimaryBoldblack,
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => _buildInput(
                          controller.studentIdText.value.isEmpty
                              ? '-'
                              : controller.studentIdText.value,
                          trailingIcon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        LocaleKeys.classLabel.tr,
                        style: AppTextStyle.regularPrimaryBoldblack,
                      ),
                      const SizedBox(height: 6),
                      Obx(() => _buildClassField(controller)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.section.tr,
                            style: AppTextStyle.regularPrimaryBoldblack,
                          ),
                          12.width,
                          Expanded(
                            child: Obx(
                              () => Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceBetween,
                                children:
                                    controller.sectionOptions
                                        .map(
                                          (section) =>
                                              _buildRadio(controller, section),
                                        )
                                        .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// SECTION 2: LEAVE DETAILS
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              LocaleKeys.requestLeaveFillInfo.tr,
              style: AppTextStyle.mediumPrimaryBoldText.copyWith(
                color: AppColor.black,
              ),
              softWrap: true,
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: _outlineRed, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${LocaleKeys.leaveFromDate.tr}:',
                      style: AppTextStyle.smallPrimaryBoldBlack,
                    ),
                    6.width,
                    Expanded(
                      child: Obx(
                        () => _dateBox(
                          controller.startDate.value,
                          onTap: controller.pickStartDate,
                        ),
                      ),
                    ),
                    10.width,
                    Text(
                      '${LocaleKeys.leaveToDate.tr}:',
                      style: AppTextStyle.smallPrimaryBoldBlack,
                    ),
                    6.width,
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
                      Text(
                        '${LocaleKeys.totalLeaveDays.tr}:',
                        style: AppTextStyle.smallPrimaryBoldBlack,
                      ),
                      8.width,
                      Container(
                        width: 56,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _leaveDaysColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _outlineRed),
                        ),
                        child: Text(
                          controller.totalDays == 0
                              ? '-'
                              : controller.totalDays.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                14.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${LocaleKeys.leaveReason.tr}: ',
                      style: AppTextStyle.smallPrimaryBoldBlack,
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _buildLeaveType(
                            controller,
                            label: LocaleKeys.sick.tr,
                            value: 'sick',
                            icon: Icons.sick_outlined,
                          ),
                          _buildLeaveType(
                            controller,
                            label: LocaleKeys.busy.tr,
                            value: 'busy',
                            icon: Icons.work_outline,
                          ),
                          _buildLeaveType(
                            controller,
                            label: LocaleKeys.other.tr,
                            value: 'other',
                            icon: Icons.more_horiz,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                14.height,
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
                        color: AppColor.red,
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
              ],
            ),
          ),

          UIConstants.spacing.height,

          /// SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.red,
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
                          final created = await controller.submitRequest();
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
          UIConstants.spacing.height,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColor.red,
                size: 15,
              ),
              6.width,
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
            ],
          ),
        ),
      );

  Widget _buildInput(String text, {IconData? trailingIcon}) => Container(
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
          Icon(trailingIcon, color: AppColor.red, size: 18),
        ],
      ],
    ),
  );

  Widget _buildClassField(RequestLeaveController controller) {
    final classText = _selectedClassText(controller);
    if (controller.classOptions.length <= 1) {
      return _buildInput(classText, trailingIcon: Icons.keyboard_arrow_down);
    }
    return _buildClassDropdown(controller);
  }

  Widget _buildClassDropdown(RequestLeaveController controller) => Obx(
    () => GestureDetector(
      onTap: () async {
        final selected = await Get.bottomSheet<List<String>>(
          _ClassMultiSelectSheet(
            options: controller.classOptions.toList(growable: false),
            selected:
                controller.selectedClasses.isEmpty
                    ? <String>[_selectedClassText(controller)]
                    : controller.selectedClasses.toList(growable: false),
          ),
        );
        if (selected != null) {
          controller.setSelectedClasses(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _outlineRed),
          borderRadius: BorderRadius.circular(_fieldRadius),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(_selectedClassText(controller))),
            const Icon(Icons.keyboard_arrow_down, color: AppColor.red),
          ],
        ),
      ),
    ),
  );

  String _selectedClassText(RequestLeaveController controller) {
    if (controller.selectedClasses.isNotEmpty) {
      return controller.selectedClasses.join(', ');
    }
    final classText =
        controller.selectedClass.value.trim().isEmpty
            ? controller.studentGradeText.value.trim()
            : controller.selectedClass.value.trim();
    return classText.isEmpty ? '-' : classText;
  }

  Widget _buildRadio(RequestLeaveController controller, String title) =>
      Obx(() {
        final isSelected = controller.selectedSection.value == title;
        return GestureDetector(
          onTap: () => controller.selectedSection.value = title,
          child: Column(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColor.red : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(title, style: AppTextStyle.smallPrimaryBoldBlack),
            ],
          ),
        );
      });

  Widget _buildLeaveType(
    RequestLeaveController controller, {
    required String label,
    required String value,
    required IconData icon,
  }) => Obx(() {
    final isSelected = controller.leaveType.value == value;
    return GestureDetector(
      onTap: () => controller.leaveType.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.red : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? AppColor.red : _outlineRed),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColor.red,
            ),
            5.width,
            Text(
              label,
              style: AppTextStyle.smallPrimaryBoldBlack.copyWith(
                color: isSelected ? Colors.white : AppColor.black,
              ),
            ),
          ],
        ),
      ),
    );
  });

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

class _ClassMultiSelectSheet extends StatefulWidget {
  const _ClassMultiSelectSheet({required this.options, required this.selected});

  final List<String> options;
  final List<String> selected;

  @override
  State<_ClassMultiSelectSheet> createState() => _ClassMultiSelectSheetState();
}

class _ClassMultiSelectSheetState extends State<_ClassMultiSelectSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    final options = widget.options.toSet();
    _selected = widget.selected.where(options.contains).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children:
                    widget.options.map((option) {
                      final isSelected = _selected.contains(option);
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: isSelected,
                        title: Text(option),
                        activeColor: AppColor.red,
                        onChanged: (_) {
                          setState(() {
                            if (isSelected) {
                              _selected.remove(option);
                            } else {
                              _selected.add(option);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.back(result: _selected.toList()),
                child: Text(LocaleKeys.done.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
