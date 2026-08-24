import 'dart:io';

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
  static const int _maxImages = 10;

  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _descriptionCtl = TextEditingController();
  String? _selectedClassValue;

  /// Existing remote images still kept on this activity (edit mode only).
  final List<ActivityImageRef> _keptRemote = [];

  /// Ids of remote images the teacher removed — sent as `delete_images` on
  /// update. The API's update contract is a delete-list, not a keep-list:
  /// anything already attached and NOT in this list is kept automatically.
  final List<int> _removedRemoteImageIds = [];

  /// Newly picked local images, not yet uploaded.
  final List<XFile> _newImages = [];

  bool get _isEditMode => widget.initialActivity != null;

  int get _totalImageCount => _keptRemote.length + _newImages.length;
  int get _remainingImageSlots => _maxImages - _totalImageCount;

  @override
  void initState() {
    super.initState();
    final initialActivity = widget.initialActivity;
    if (initialActivity != null) {
      _titleCtl.text = initialActivity.title;
      _descriptionCtl.text = initialActivity.description;
      _keptRemote.addAll(initialActivity.imageRefs);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _SectionTitle(
                    titleKey: LocaleKeys.coverImage,
                    subtitleKey: LocaleKeys.coverImageSubtitle,
                  ),
                ),
                Text(
                  '$_totalImageCount/$_maxImages',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _remainingImageSlots <= 0 ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: Text(
                _totalImageCount == 0
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
            const SizedBox(height: 10),
            if (_totalImageCount > 0)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final ref in _keptRemote)
                    _ImageTile(
                      key: ValueKey('kept-${ref.id ?? ref.url}'),
                      onRemove: () => _removeKeptImage(ref),
                      child: ResolvedNetworkImage(
                        rawPath: ref.url,
                        width: 92,
                        height: 92,
                      ),
                    ),
                  for (final file in _newImages)
                    _ImageTile(
                      key: ValueKey('new-${file.path}'),
                      onRemove: () => setState(() => _newImages.remove(file)),
                      child: Image.file(
                        File(file.path),
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 92,
                              height: 92,
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
              )
            else
              Text(
                _isEditMode
                    ? LocaleKeys.coverImageReplaceHint.tr
                    : LocaleKeys.coverImageOptionalHint.tr,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Color(0xFF6B7280),
                ),
              ),
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

  void _removeKeptImage(ActivityImageRef ref) {
    setState(() => _keptRemote.remove(ref));
    if (ref.id != null) {
      _removedRemoteImageIds.add(ref.id!);
      return;
    }
    // No id to send in delete_images — the server has no way to know which
    // attachment this was, so it will still be there after save. Tell the
    // teacher rather than silently pretending the removal worked.
    Get.snackbar(
      LocaleKeys.error.tr,
      LocaleKeys.imageRemovalNotSupportedMessage.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _pickImages() async {
    // Capture the room available *before* the pick — pickMultiImage's
    // `limit` is a hint some platforms ignore, so we re-clamp here rather
    // than trust it.
    final room = _remainingImageSlots;
    if (room <= 0) {
      Get.snackbar(
        LocaleKeys.error.tr,
        LocaleKeys.maxImagesReachedMessage.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(limit: room);
      // Cancel returns an empty list, not null — bail out before touching
      // state so cancelling never wipes an existing selection.
      if (!mounted || picked.isEmpty) return;
      setState(() {
        _newImages.addAll(picked.take(room));
      });
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

    final description = _descriptionCtl.text.trim();
    if (description.isEmpty) {
      Get.snackbar(
        LocaleKeys.error.tr,
        LocaleKeys.activityDescriptionEmpty.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final imagePaths = _newImages.map((file) => file.path).toList();
      // The gallery displays kept remote images first, then new picks — so
      // the true "first image" is only one of the new files when there's
      // no kept remote image ahead of it. A kept remote image can't become
      // the cover here since we'd need to download it before re-sending it
      // as binary.
      final coverImagePath =
          _keptRemote.isEmpty && _newImages.isNotEmpty
              ? _newImages.first.path
              : null;
      if (_isEditMode) {
        await controller.updateActivity(
          id: widget.initialActivity!.id,
          classId: selectedClassId,
          title: title,
          description: description,
          imagePaths: imagePaths,
          deleteImageIds: _removedRemoteImageIds,
          coverImagePath: coverImagePath,
        );
      } else {
        await controller.createActivity(
          classId: selectedClassId,
          title: title,
          description: description,
          imagePaths: imagePaths,
          coverImagePath: coverImagePath,
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

/// A single 92x92 image thumbnail with a circular remove button, used by
/// both the kept-remote and newly-picked image grids.
class _ImageTile extends StatelessWidget {
  const _ImageTile({super.key, required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 92, height: 92, child: child),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFD14343),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
