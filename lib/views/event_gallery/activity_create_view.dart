import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/event_gallery/controller.dart';

class TeacherCreateActivityView extends StatefulWidget {
  const TeacherCreateActivityView({super.key, this.initialActivity});

  final ClassActivityItem? initialActivity;

  @override
  State<TeacherCreateActivityView> createState() =>
      _TeacherCreateActivityViewState();
}

class _TeacherCreateActivityViewState extends State<TeacherCreateActivityView> {
  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _descriptionCtl = TextEditingController();
  String? _selectedClassValue;
  XFile? _selectedImage;

  bool get _isEditMode => widget.initialActivity != null;

  @override
  void initState() {
    super.initState();
    final initialActivity = widget.initialActivity;
    if (initialActivity != null) {
      _titleCtl.text = initialActivity.title;
      _descriptionCtl.text = initialActivity.description;
      final className = initialActivity.className.trim();
      if (className.isNotEmpty) {
        _selectedClassValue =
            Get.find<ActivityController>().teacherClassOptions
                .firstWhereOrNull((option) => option.name == className)
                ?.value;
      } else if (initialActivity.classId != null) {
        _selectedClassValue = initialActivity.classId.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descriptionCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActivityController>();
    final options = controller.teacherClassOptions;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? LocaleKeys.editActivity.tr
              : LocaleKeys.createActivity.tr,
        ),
        centerTitle: true,
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              titleKey: LocaleKeys.classTarget,
              subtitleKey: LocaleKeys.classTargetSubtitle,
            ),
            const SizedBox(height: 10),
            Obx(() {
              final opts = options.toList(growable: false);
              if (_isEditMode &&
                  _selectedClassValue == null &&
                  (widget.initialActivity?.className.trim().isNotEmpty ??
                      false)) {
                final matched = opts.firstWhereOrNull(
                  (item) =>
                      item.name == widget.initialActivity!.className.trim(),
                );
                if (matched != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() => _selectedClassValue = matched.value);
                  });
                }
              }
              final selectedValue =
                  opts.any((item) => item.value == _selectedClassValue)
                      ? _selectedClassValue
                      : null;

              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: _fieldDecoration(
                  hintText: LocaleKeys.selectClass.tr,
                  prefixIcon: Icons.groups_rounded,
                ),
                isExpanded: true,
                dropdownColor: Colors.white,
                items: opts
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.value,
                        child: Text(
                          option.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged:
                    opts.isEmpty || controller.isSubmittingActivity.value
                        ? null
                        : (value) =>
                            setState(() => _selectedClassValue = value),
                disabledHint: Text(
                  opts.isEmpty
                      ? LocaleKeys.noClassAvailable.tr
                      : LocaleKeys.selectClass.tr,
                ),
              );
            }),
            const SizedBox(height: 24),
            _SectionTitle(
              titleKey: LocaleKeys.activityContent,
              subtitleKey: LocaleKeys.activityContentSubtitle,
            ),
            const SizedBox(height: 10),
            _FieldLabel(LocaleKeys.activityTitleLabel.tr),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtl,
              onChanged: (_) => setState(() {}),
              decoration: _fieldDecoration(
                hintText: LocaleKeys.activityTitleHint.tr,
                prefixIcon: Icons.title_rounded,
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel(LocaleKeys.descriptionLabel.tr),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionCtl,
              minLines: 5,
              maxLines: 7,
              onChanged: (_) => setState(() {}),
              decoration: _fieldDecoration(
                hintText: LocaleKeys.descriptionHint.tr,
                prefixIcon: Icons.notes_rounded,
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              titleKey: LocaleKeys.coverImage,
              subtitleKey: LocaleKeys.coverImageSubtitle,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_rounded),
              label: Text(
                _selectedImage == null
                    ? LocaleKeys.chooseImage.tr
                    : LocaleKeys.changeImage.tr,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColor.primary,
                side: const BorderSide(color: AppColor.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedImage == null
                  ? (_isEditMode &&
                          (widget.initialActivity?.image.trim().isNotEmpty ??
                              false)
                      ? LocaleKeys.coverImageReplaceHint.tr
                      : LocaleKeys.coverImageOptionalHint.tr)
                  : LocaleKeys.imageSelectedReady.tr,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Color(0xFF6B7280),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_selectedImage!.path),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ] else if (_isEditMode &&
                (widget.initialActivity?.image.trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.initialActivity!.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => Container(color: const Color(0xFFE9EEF2)),
                  errorWidget:
                      (_, __, ___) => Container(
                        height: 180,
                        color: const Color(0xFFE9EEF2),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      controller.isSubmittingActivity.value ? null : _submit,
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
                          : const Icon(Icons.send_rounded),
                  label: Text(
                    controller.isSubmittingActivity.value
                        ? LocaleKeys.submitting.tr
                        : (_isEditMode
                            ? LocaleKeys.updateActivity.tr
                            : LocaleKeys.createAndNotifyStudents.tr),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColor.primary,
                    disabledBackgroundColor: AppColor.primary.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: AppColor.primary, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted || image == null) return;
      setState(() => _selectedImage = image);
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> _submit() async {
    final controller = Get.find<ActivityController>();
    if (controller.isSubmittingActivity.value) {
      return;
    }
    final title = _titleCtl.text.trim();
    final selectedClassId = _selectedClassValue;

    if (selectedClassId == null || selectedClassId.trim().isEmpty) {
      Get.snackbar(
        LocaleKeys.error.tr,
        LocaleKeys.pleaseSelectClass.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (title.isEmpty) {
      Get.snackbar(
        LocaleKeys.error.tr,
        LocaleKeys.activityTitleEmpty.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (_isEditMode) {
        await controller.updateActivity(
          id: widget.initialActivity!.id,
          classId: selectedClassId,
          title: title,
          description: _descriptionCtl.text.trim(),
          imagePath: _selectedImage?.path ?? '',
        );
      } else {
        await controller.createActivity(
          classId: selectedClassId,
          title: title,
          description: _descriptionCtl.text.trim(),
          imagePath: _selectedImage?.path ?? '',
        );
      }
      if (!mounted) return;
      Get.back(result: true);
      final snackbarTitle = LocaleKeys.success.tr;
      final snackbarMessage =
          _isEditMode
              ? LocaleKeys.activityUpdatedSuccess.tr
              : LocaleKeys.activityCreatedSuccess.tr;
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.titleKey, required this.subtitleKey});

  final String titleKey;
  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleKey.tr,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitleKey.tr,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
      ),
    );
  }
}
