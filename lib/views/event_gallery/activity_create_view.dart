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
    final selectedOption = controller.teacherClassOptions.firstWhereOrNull(
      (item) => item.value == _selectedClassValue,
    );
    final selectedClass = (selectedOption?.name ?? '').trim();
    final previewTitle = _titleCtl.text.trim();
    final previewBody = _descriptionCtl.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Activity' : 'Create Activity'),
        centerTitle: true,
        backgroundColor: const Color(0xFF153D6F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF153D6F), Color(0xFF0D5C4F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140D5C4F),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
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
                      color: const Color(0x1FFFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isEditMode ? 'Edit Mode' : 'New Post',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _isEditMode
                        ? 'Refresh the activity before students see the newest version.'
                        : 'Create a polished class update students can open right away.',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isEditMode
                        ? 'Review the class target, update the message, and replace the cover image if needed.'
                        : 'Choose the class, shape the message, and preview the push notification before posting.',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xD9FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    title: 'Class Target',
                    subtitle:
                        'Choose which class should receive this activity.',
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    final options = controller.teacherClassOptions.toList(
                      growable: false,
                    );
                    if (_isEditMode &&
                        _selectedClassValue == null &&
                        (widget.initialActivity?.className.trim().isNotEmpty ??
                            false)) {
                      final matched = options.firstWhereOrNull(
                        (item) =>
                            item.name ==
                            widget.initialActivity!.className.trim(),
                      );
                      if (matched != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() => _selectedClassValue = matched.value);
                        });
                      }
                    }
                    final selectedValue =
                        options.any((item) => item.value == _selectedClassValue)
                            ? _selectedClassValue
                            : null;

                    return DropdownButtonFormField<String>(
                      value: selectedValue,
                      decoration: _fieldDecoration(
                        hintText: 'Select class',
                        prefixIcon: Icons.groups_rounded,
                      ),
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      items: options
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option.value,
                              child: Text(
                                option.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged:
                          options.isEmpty ||
                                  controller.isSubmittingActivity.value
                              ? null
                              : (value) =>
                                  setState(() => _selectedClassValue = value),
                      disabledHint: Text(
                        options.isEmpty ? 'No class available' : 'Select class',
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    title: 'Notification Preview',
                    subtitle:
                        'This is the push message students in the selected class will receive.',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF6F3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: AppColor.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery Topic',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedClass.isEmpty
                                  ? 'Choose a class to target a topic.'
                                  : 'class_$selectedClass',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FBFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          previewTitle.isEmpty
                              ? (_isEditMode
                                  ? 'Updated Class Activity'
                                  : 'New Class Activity')
                              : previewTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          previewBody.isEmpty
                              ? 'Students will see the activity description here.'
                              : previewBody,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    title: 'Activity Content',
                    subtitle:
                        'Write the title and short description students should read first.',
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Activity Title'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtl,
                    onChanged: (_) => setState(() {}),
                    decoration: _fieldDecoration(
                      hintText: 'For example: Science lab, Reading circle',
                      prefixIcon: Icons.title_rounded,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionCtl,
                    minLines: 5,
                    maxLines: 7,
                    onChanged: (_) => setState(() {}),
                    decoration: _fieldDecoration(
                      hintText: 'Write a short summary .',
                      prefixIcon: Icons.notes_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    title: 'Cover Image',
                    subtitle:
                        'Add one visual to make the activity card more engaging.',
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_rounded),
                    label: Text(
                      _selectedImage == null ? 'Choose Image' : 'Change Image',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: AppColor.primary,
                      side: const BorderSide(color: Color(0xFFCCE0DA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _selectedImage == null
                        ? (_isEditMode &&
                                (widget.initialActivity?.image
                                        .trim()
                                        .isNotEmpty ??
                                    false)
                            ? 'Optional. Choose a new image only if you want to replace the current one.'
                            : 'Optional. Add one cover image to make the activity card more engaging.')
                        : 'Image selected and ready to upload.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(_selectedImage!.path),
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ] else if (_isEditMode &&
                      (widget.initialActivity?.image.trim().isNotEmpty ??
                          false)) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: widget.initialActivity!.image,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) =>
                                Container(color: const Color(0xFFE9EEF2)),
                        errorWidget:
                            (_, __, ___) => Container(
                              height: 190,
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D5C4F), Color(0xFF137A68)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x220D5C4F),
                      blurRadius: 16,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
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
                          ? 'Submitting...'
                          : (_isEditMode
                              ? 'Update Activity'
                              : 'Create and Notify Students'),
                    ),

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
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
      fillColor: const Color(0xFFF9FBFB),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF0D5C4F), size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD5DEDB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD5DEDB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        'Please select a class',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (title.isEmpty) {
      Get.snackbar(
        LocaleKeys.error.tr,
        'Activity title cannot be empty',
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
      const snackbarTitle = 'Success';
      final snackbarMessage =
          _isEditMode
              ? 'Activity updated successfully'
              : 'Activity created successfully';
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
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
