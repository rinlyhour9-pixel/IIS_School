part of 'homework_widget.dart';

class _AssignHomeworkPanel extends StatefulWidget {
  const _AssignHomeworkPanel({
    this.id,
    this.title,
    this.description,
    this.classId,
    this.className,
    this.deadline,
    this.attachmentUrl,
    this.submitted = 0,
    this.total = 0,
    this.showTitle = true,
  });

  final String? id;
  final String? title;
  final String? description;
  final int? classId;
  final String? className;
  final String? deadline;
  final String? attachmentUrl;
  final int submitted;
  final int total;
  final bool showTitle;

  @override
  State<_AssignHomeworkPanel> createState() => _AssignHomeworkPanelState();
}

class _AssignHomeworkPanelState extends State<_AssignHomeworkPanel> {
  late final TextEditingController _titleCtl;
  late final TextEditingController _descriptionCtl;
  late final TextEditingController _deadlineCtl;
  int? _selectedClassId;
  String _selectedAttachmentPath = '';
  String _selectedAttachmentName = '';
  Uint8List? _selectedAttachmentBytes;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.title ?? '');
    _descriptionCtl = TextEditingController(text: widget.description ?? '');
    _deadlineCtl = TextEditingController(text: widget.deadline ?? '');
    _selectedClassId = widget.classId;
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descriptionCtl.dispose();
    _deadlineCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeworkController>();
    final existingAttachment = (widget.attachmentUrl ?? '').trim();
    return Obx(() {
      if (controller.teacherClassOptions.isEmpty &&
          !controller.isTeacherClassOptionsLoading.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchTeacherClassOptions();
        });
      }
      final classOptions = <int, HomeworkClassOption>{};
      for (final option in controller.teacherClassOptions) {
        final id = option.id;
        if (id == null || id <= 0 || option.name.trim().isEmpty) continue;
        classOptions[id] = option;
      }
      final options = classOptions.values.toList(growable: false);
      final initialClassName = (widget.className ?? '').trim().toLowerCase();
      final selectedId =
          _selectedClassId != null && classOptions.containsKey(_selectedClassId)
              ? _selectedClassId
              : (initialClassName.isNotEmpty
                  ? options
                      .firstWhereOrNull(
                        (option) =>
                            option.name.trim().toLowerCase() ==
                            initialClassName,
                      )
                      ?.id
                  : null);
      if (_selectedClassId != selectedId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _selectedClassId = selectedId);
        });
      }

      return _Panel(
        title: LocaleKeys.onlineClassActionAssignHomework.tr,
        showTitle: widget.showTitle,
        children: [
          _FieldLabel(title: LocaleKeys.onlineClassSelectClass.tr),
          const SizedBox(height: 8),
          _ClassDropdownField(
            value: selectedId,
            options: options,
            isEnabled: !controller.isSubmittingAssignment.value,
            onChanged: (value) => setState(() => _selectedClassId = value),
          ),
          if (options.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              controller.isTeacherClassOptionsLoading.value
                  ? LocaleKeys.onlineClassLoadingClassList.tr
                  : LocaleKeys.onlineClassNoClassAvailableYet.tr,
              style: AppTextStyle.smallGreyRegular.copyWith(
                color: _homeworkMutedText,
              ),
            ),
          ],
          const SizedBox(height: 22),
          _FieldLabel(title: LocaleKeys.onlineClassHomeworkTitle.tr),
          const SizedBox(height: 8),
          _StaticInput(
            icon: Icons.title_rounded,
            label: LocaleKeys.onlineClassEnterHomeworkTitle.tr,
            controller: _titleCtl,
          ),
          const SizedBox(height: 22),
          _FieldLabel(title: LocaleKeys.onlineClassHomeworkDescription.tr),
          const SizedBox(height: 8),
          _StaticInput(
            icon: Icons.notes_rounded,
            label: LocaleKeys.onlineClassEnterHomeworkDescription.tr,
            minHeight: 78,
            controller: _descriptionCtl,
          ),
          const SizedBox(height: 22),
          _FieldLabel(title: LocaleKeys.onlineClassDeadline.tr),
          const SizedBox(height: 8),
          _DeadlinePickerField(controller: _deadlineCtl, onTap: _pickDeadline),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _UploadButton(
                  icon: Icons.attach_file_rounded,
                  label:
                      _selectedAttachmentName.isEmpty
                          ? LocaleKeys.onlineClassUploadPictureOrPdf.tr
                          : _selectedAttachmentName,
                  onPressed: _pickAttachment,
                ),
              ),
            ],
          ),
          if (_selectedAttachmentPath.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SelectedHomeworkAttachmentPreview(
              path: _selectedAttachmentPath,
              name: _selectedAttachmentName,
              bytes: _selectedAttachmentBytes,
            ),
          ] else ...[
            if (existingAttachment.isNotEmpty) ...[
              const SizedBox(height: 14),
              _ExistingHomeworkAttachment(url: existingAttachment),
            ],
          ],
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 66,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3345), Color(0xFFD80F23)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33D80F23),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed:
                      controller.isSubmittingAssignment.value ? null : _submit,
                  icon:
                      controller.isSubmittingAssignment.value
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send_rounded, size: 22),
                  label: Text(
                    controller.isSubmittingAssignment.value
                        ? LocaleKeys.onlineClassSubmitting.tr
                        : LocaleKeys.submit.tr,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _submit() async {
    final title = _titleCtl.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        LocaleKeys.error.tr,
        '${LocaleKeys.onlineClassHomeworkTitle.tr} ${LocaleKeys.cannotBeEmpty.tr}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final controller = Get.find<HomeworkController>();
    final selectedOption = controller.teacherClassOptions.firstWhereOrNull(
      (option) => option.id == _selectedClassId,
    );
    if (selectedOption == null) {
      Get.snackbar(
        LocaleKeys.error.tr,
        LocaleKeys.onlineClassPleaseSelectClass.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedOption.id == null || selectedOption.id! <= 0) {
      Get.snackbar(
        LocaleKeys.error.tr,
        LocaleKeys.onlineClassMissingClassId.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    HomeworkAssignment item;
    try {
      if ((widget.id ?? '').trim().isEmpty) {
        item = await controller.createAssignment(
          title: title,
          classId: selectedOption.id,
          className: selectedOption.name,
          deadline: _deadlineCtl.text,
          description: _descriptionCtl.text.trim(),
          attachmentPath: _selectedAttachmentPath,
        );
      } else {
        item = await controller.updateAssignment(
          id: widget.id ?? '',
          classId: selectedOption.id,
          title: title,
          className: selectedOption.name,
          deadline: _deadlineCtl.text,
          description: _descriptionCtl.text.trim(),
          submitted: widget.submitted,
          total: widget.total,
          attachmentPath: _selectedAttachmentPath,
        );
      }
    } catch (e) {
      ExceptionHandler.handleException(e);
      return;
    }

    await controller.fetchTeacherHomeworks();
    Get.snackbar(
      LocaleKeys.onlineClassSuccessTitle.tr,
      (widget.id ?? '').trim().isEmpty
          ? LocaleKeys.youHaveSuccessfullyCreated.tr
          : LocaleKeys.onlineClassUpdatedSuccessfully.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF14925A),
      colorText: Colors.white,
    );

    if (widget.showTitle) {
      controller.requestAssignmentsLoading();
      Navigator.of(context).pushReplacement(
        _homeworkRoute(
          _TeacherActionDetailScreen(
            title: LocaleKeys.onlineClassActionAllAssignHomework.tr,
            child: const _AllAssignedHomeworkPanel(),
          ),
        ),
      );
      return;
    }

    controller.requestAssignmentsLoading();
    Navigator.of(context).pop(item);
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    _deadlineCtl.text = Get.find<HomeworkController>().formatDeadline(picked);
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        withData: true,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf'],
      );
      final file = result?.files.single;
      if (!mounted || file == null || (file.path ?? '').trim().isEmpty) return;
      setState(() {
        _selectedAttachmentPath = file.path!.trim();
        _selectedAttachmentName = file.name.trim();
        _selectedAttachmentBytes = file.bytes;
      });
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }
}

class _SelectedHomeworkAttachmentPreview extends StatelessWidget {
  const _SelectedHomeworkAttachmentPreview({
    required this.path,
    required this.name,
    this.bytes,
  });

  final String path;
  final String name;
  final Uint8List? bytes;

  bool get _isImage {
    final lower = name.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child:
            bytes != null
                ? Image.memory(
                  bytes!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                : Image.file(
                  File(path),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _onlineClassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_rounded, color: _onlineClassAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: AppTextStyle.smallPrimaryBold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassDetailPanel extends StatelessWidget {
  const _ClassDetailPanel();

  @override
  Widget build(BuildContext context) {
    return GetX<HomeworkController>(
      builder: (controller) {
        final dashboard = controller.teacherDashboard.value;
        final isLoading = controller.isTeacherDashboardLoading.value;

        return _Panel(
          title: LocaleKeys.onlineClassActionClassDetail.tr,
          children: [
            _DashboardClassDropdown(
              options: controller.teacherDashboardClassLabels,
              isLoading: isLoading,
              selectedIndex:
                  controller.selectedTeacherDashboardClassIndex.value,
              onChanged: (index) {
                controller.selectedTeacherDashboardClassIndex.value = index;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ClassInfoStat(
                    icon: Icons.class_rounded,
                    value:
                        isLoading ? '...' : '${dashboard?.totalClasses ?? 0}',
                    label: LocaleKeys.onlineClassTotalClass.tr,
                    color: const Color(0xFFF3B51B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ClassInfoStat(
                    icon: Icons.groups_rounded,
                    value:
                        isLoading ? '...' : '${dashboard?.totalStudents ?? 0}',
                    label: LocaleKeys.onlineClassStudents.tr,
                    color: const Color(0xFF10A850),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _ClassDetailTile(
              icon: Icons.info_outline_rounded,
              title: 'Dashboard source',
              value: 'Teacher homework dashboard API',
            ),
            const SizedBox(height: 10),
            _ClassDetailTile(
              icon: Icons.analytics_outlined,
              title: 'Latest response',
              value:
                  isLoading
                      ? 'Loading summary...'
                      : '${dashboard?.totalClasses ?? 0} classes, ${dashboard?.totalStudents ?? 0} students',
            ),
          ],
        );
      },
    );
  }
}

class _DashboardClassDropdown extends StatelessWidget {
  const _DashboardClassDropdown({
    required this.options,
    required this.isLoading,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final bool isLoading;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeIndex =
        options.isEmpty
            ? 0
            : selectedIndex.clamp(0, options.length - 1).toInt();
    final selectedValue = options.isEmpty ? null : options[safeIndex];

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isLoading ? _onlineClassAccentLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _onlineClassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF7F8),
              border: Border(right: BorderSide(color: _onlineClassBorder)),
            ),
            child: const Icon(
              Icons.class_rounded,
              color: _onlineClassAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                hint: Text(
                  isLoading ? 'Loading classes...' : 'No classes available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColor.darkGrey,
                ),
                style: AppTextStyle.normalPrimaryRegular,
                items:
                    options
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    options.isEmpty
                        ? null
                        : (value) {
                          if (value == null) return;
                          final index = options.indexOf(value);
                          if (index != -1) {
                            onChanged(index);
                          }
                        },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllAssignedHomeworkPanel extends StatefulWidget {
  const _AllAssignedHomeworkPanel();

  @override
  State<_AllAssignedHomeworkPanel> createState() =>
      _AllAssignedHomeworkPanelState();
}

class _AllAssignedHomeworkPanelState extends State<_AllAssignedHomeworkPanel> {
  final HomeworkController controller = Get.find<HomeworkController>();
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.shouldShowAssignmentsLoading = false;
      controller.fetchAllTeacherHomeworks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.assignedHomeworkItems;
      if (controller.isAssignmentsLoading.value) {
        return const SizedBox(
          height: 320,
          child: Center(
            child: SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: _onlineClassAccent,
                backgroundColor: _onlineClassAccentSoft,
              ),
            ),
          ),
        );
      }
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }

      final allItems = items.toList(growable: false);
      final pendingItems =
          allItems.where((item) => item.total > item.submitted).toList();
      final submittedItems =
          allItems.where((item) => item.submitted > 0).toList();
      final visibleItems =
          _selectedFilterIndex == 1
              ? pendingItems
              : _selectedFilterIndex == 2
              ? submittedItems
              : allItems;
      final totalSubmissions = allItems.fold<int>(
        0,
        (sum, item) => sum + item.total,
      );
      final submittedSubmissions = allItems.fold<int>(
        0,
        (sum, item) => sum + item.submitted,
      );
      final progress =
          totalSubmissions == 0 ? 0.0 : submittedSubmissions / totalSubmissions;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$submittedSubmissions/$totalSubmissions ${LocaleKeys.onlineClassSubmitted.tr}',
                  style: AppTextStyle.smallGreyRegular.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyle.smallPrimaryBold.copyWith(
                  color: _onlineClassAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE9E9E9),
              valueColor: const AlwaysStoppedAnimation(_onlineClassAccent),
            ),
          ),
          const SizedBox(height: 16),
          _TeacherHomeworkFilterTabs(
            selectedIndex: _selectedFilterIndex,
            allCount: allItems.length,
            pendingCount: pendingItems.length,
            submittedCount: submittedItems.length,
            onChanged: (index) => setState(() => _selectedFilterIndex = index),
          ),
          const SizedBox(height: 16),
          ...visibleItems.map(
            (item) => _AssignedHomeworkAttendanceCard(
              item: item,
              onTap:
                  () => Navigator.of(context).push(
                    _homeworkRoute(
                      _TeacherActionDetailScreen(
                        title: LocaleKeys.onlineClassActionAllAssignHomework.tr,
                        child: _AssignedHomeworkDetailPanel(item: item),
                      ),
                    ),
                  ),
              onEdit: () async {
                HomeworkAssignment editItem = item;
                try {
                  final detail = await controller.fetchTeacherHomeworkDetail(
                    item.id,
                  );
                  editItem = detail.assignment;
                } catch (_) {}

                if (!context.mounted) return;
                Navigator.of(context).push(
                  _homeworkRoute(
                    _TeacherActionDetailScreen(
                      title: LocaleKeys.onlineClassEdit.tr,
                      child: _AssignedHomeworkEditPanel(item: editItem),
                    ),
                  ),
                );
              },
            ),
          ),
          if (controller.hasMoreTeacherHomeworkPages ||
              controller.isTeacherAssignmentsLoadingMore.value) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child:
                  controller.isTeacherAssignmentsLoadingMore.value
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: _onlineClassAccent,
                          ),
                        ),
                      )
                      : OutlinedButton(
                        onPressed: controller.loadMoreTeacherHomeworks,
                        child: Text(
                          'Load more (${controller.teacherHomeworkCurrentPage.value}/${controller.teacherHomeworkLastPage.value})',
                        ),
                      ),
            ),
          ],
        ],
      );
    });
  }
}

class _TeacherHomeworkFilterTabs extends StatelessWidget {
  const _TeacherHomeworkFilterTabs({
    required this.selectedIndex,
    required this.allCount,
    required this.pendingCount,
    required this.submittedCount,
    required this.onChanged,
  });

  final int selectedIndex;
  final int allCount;
  final int pendingCount;
  final int submittedCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = [
      '${LocaleKeys.all.tr} ($allCount)',
      '${LocaleKeys.onlineClassPending.tr} ($pendingCount)',
      '${LocaleKeys.onlineClassSubmitted.tr} ($submittedCount)',
    ];

    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _onlineClassBorder),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          selectedIndex == index
                              ? _onlineClassAccent
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[index],
                        maxLines: 1,
                        style: AppTextStyle.smallPrimaryBold.copyWith(
                          color:
                              selectedIndex == index
                                  ? Colors.white
                                  : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClassInfoStat extends StatelessWidget {
  const _ClassInfoStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.mediumPrimaryBold.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.smallGreyRegular.copyWith(
                    color: _homeworkMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassDetailTile extends StatelessWidget {
  const _ClassDetailTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _onlineClassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _onlineClassAccentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _onlineClassAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.smallGreyRegular.copyWith(
                    color: _homeworkMutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.normalPrimaryBold.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedHomeworkDetailPanel extends StatefulWidget {
  const _AssignedHomeworkDetailPanel({required this.item});

  final HomeworkAssignment item;

  @override
  State<_AssignedHomeworkDetailPanel> createState() =>
      _AssignedHomeworkDetailPanelState();
}

class _AssignedHomeworkDetailPanelState
    extends State<_AssignedHomeworkDetailPanel> {
  String _selectedStatus = LocaleKeys.onlineClassSubmitted;
  late Future<HomeworkAssignmentDetail> _detailFuture;
  @override
  void initState() {
    super.initState();
    _reloadDetail();
  }

  void _reloadDetail() {
    _detailFuture = Get.find<HomeworkController>().fetchTeacherHomeworkDetail(
      widget.item.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeworkAssignmentDetail>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 320,
            child: Center(
              child: SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _onlineClassAccent,
                  backgroundColor: _onlineClassAccentSoft,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _Panel(
            title: widget.item.title,
            children: [
              Text(
                'Homework detail is not available.',
                style: AppTextStyle.smallGreyRegular.copyWith(
                  color: _homeworkMutedText,
                ),
              ),
            ],
          );
        }

        final detail = snapshot.data!;
        final item = detail.assignment;
        final submittedCount =
            detail.students
                .where((submission) => submission.status == 'submitted')
                .length;
        final pendingCountFromStudents =
            detail.students
                .where((submission) => submission.status != 'submitted')
                .length;
        final pendingCount =
            pendingCountFromStudents > 0
                ? pendingCountFromStudents
                : (item.total > submittedCount
                    ? item.total - submittedCount
                    : 0);
        final filtered =
            detail.students
                .where(
                  (submission) =>
                      _statusKeyFor(submission.status) == _selectedStatus,
                )
                .toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AssignedHomeworkSummaryPanel(item: item),
            const SizedBox(height: 14),
            _Panel(
              title: LocaleKeys.onlineClassAllStudentSubmissions.tr,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _submissionMetricBox(
                        value: '$submittedCount',
                        label: LocaleKeys.onlineClassSubmitted.tr,
                        statusKey: LocaleKeys.onlineClassSubmitted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _submissionMetricBox(
                        value: '$pendingCount',
                        label: LocaleKeys.onlineClassPending.tr,
                        statusKey: LocaleKeys.onlineClassPending,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Text(
                    'No student submissions',
                    style: AppTextStyle.smallGreyRegular.copyWith(
                      color: _homeworkMutedText,
                    ),
                  ),
                ...filtered.expand(
                  (submission) => [
                    _StudentSubmissionRow(
                      homeworkId: item.id,
                      submission: submission,
                      name: submission.name,
                      statusKey: _statusKeyFor(submission.status),
                      onSubmitted: () {
                        setState(_reloadDetail);
                      },
                    ),
                    if (submission != filtered.last) const Divider(height: 16),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _statusKeyFor(String status) {
    return status.toLowerCase() == 'submitted'
        ? LocaleKeys.onlineClassSubmitted
        : LocaleKeys.onlineClassPending;
  }

  Widget _submissionMetricBox({
    required String value,
    required String label,
    required String statusKey,
  }) {
    final selected = _selectedStatus == statusKey;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedStatus = statusKey),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              selected
                  ? Border.all(color: _onlineClassAccent, width: 1.4)
                  : null,
        ),
        child: _MetricBox(value: value, label: label),
      ),
    );
  }
}

class _AssignedHomeworkEditPanel extends StatelessWidget {
  const _AssignedHomeworkEditPanel({required this.item});

  final HomeworkAssignment item;

  @override
  Widget build(BuildContext context) {
    return _AssignHomeworkPanel(
      id: item.id,
      title: item.title,
      description: item.description,
      classId: item.classId,
      className: item.className,
      deadline: item.deadline,
      attachmentUrl: item.attachmentUrl,
      submitted: item.submitted,
      total: item.total,
      showTitle: false,
    );
  }
}

class _ExistingHomeworkAttachment extends StatelessWidget {
  const _ExistingHomeworkAttachment({
    required this.url,
    this.label = 'Current uploaded image',
    this.imageHeight = 180,
  });

  final String url;
  final String label;
  final double imageHeight;

  bool get _isImage {
    final lower = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  String get _fileName {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return url.split('/').last;
  }

  bool get _isLocalPath {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    final scheme = uri?.scheme.toLowerCase() ?? '';
    if (scheme == 'http' || scheme == 'https') {
      return false;
    }
    return trimmed.startsWith('/') || trimmed.contains(':\\');
  }

  Widget _buildAttachmentImage() {
    if (_isLocalPath) {
      return Image.file(
        File(url),
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Image.asset(
              AssetPath.placeholder.path,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
      );
    }

    return CustomNetworkImage(
      imageUrl: url,
      height: imageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      fallbackImagePath: AssetPath.placeholder.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.smallGreyRegular.copyWith(
              color: _homeworkMutedText,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildAttachmentImage(),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _onlineClassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file_rounded, color: _onlineClassAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _fileName,
              style: AppTextStyle.smallPrimaryBold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => UrlLauncherManager.launch(url),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _AssignedHomeworkSummaryPanel extends StatelessWidget {
  const _AssignedHomeworkSummaryPanel({required this.item});

  final HomeworkAssignment item;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: item.title,
      children: [
        if (item.description.isNotEmpty) ...[
          Text(
            item.description,
            style: AppTextStyle.normalPrimaryRegular.copyWith(
              color: _homeworkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
        ],
        const Divider(height: 1, color: _onlineClassBorder),
        const SizedBox(height: 14),
        _HomeworkDetailPair(
          leftLabel: LocaleKeys.classLabel.tr,
          leftValue: item.className,
          rightLabel: LocaleKeys.onlineClassDeadline.tr,
          rightValue: item.deadline,
        ),
        if (item.attachmentUrl.isNotEmpty) ...[
          const SizedBox(height: 14),
          _ExistingHomeworkAttachment(
            url: item.attachmentUrl,
            label: 'Attachment',
          ),
        ],
        const SizedBox(height: 14),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _MetricBox(
        //         value: '${item.submitted}',
        //         label: LocaleKeys.onlineClassSubmitted.tr,
        //         accentColor: const Color(0xFF14925A),
        //       ),
        //     ),
        //     const SizedBox(width: 10),
        //     Expanded(
        //       child: _MetricBox(
        //         value: '${item.total - item.submitted}',
        //         label: LocaleKeys.onlineClassPending.tr,
        //         accentColor: _onlineClassAccent,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class _HomeworkDetailPair extends StatelessWidget {
  const _HomeworkDetailPair({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HomeworkDetailText(label: leftLabel, value: leftValue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HomeworkDetailText(
            label: rightLabel,
            value: rightValue,
            crossAxisAlignment: CrossAxisAlignment.end,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _HomeworkDetailText extends StatelessWidget {
  const _HomeworkDetailText({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: AppTextStyle.smallGreyRegular.copyWith(
            color: _homeworkMutedText,
          ),
        ),
        const SizedBox(height: 0),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: AppTextStyle.normalPrimaryBold.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}

class _AssignedHomeworkAttendanceCard extends StatelessWidget {
  const _AssignedHomeworkAttendanceCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
  });

  final HomeworkAssignment item;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final accentColor = _homeworkAccentFor(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: _HomeworkAccentCardFrame(
        accentColor: accentColor,
        stripWidth: 18,
        cardRadius: 14,
        shadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.normalPrimaryBold.copyWith(
                      color: Colors.black,
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.smallGreyRegular.copyWith(
                        color: _homeworkMutedText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  _infoRow(
                    Icons.bookmark_rounded,
                    LocaleKeys.classLabel.tr,
                    item.className,
                  ),
                  const SizedBox(height: 5),
                  _infoRow(
                    Icons.calendar_month_rounded,
                    LocaleKeys.onlineClassDeadline.tr,
                    item.deadline,
                  ),
                  if (item.attachmentUrl.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _ExistingHomeworkAttachment(
                      url: item.attachmentUrl,
                      label: 'Attachment',
                      imageHeight: 140,
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _submissionChip,
                      const Spacer(),
                      _AssignedHomeworkDeleteButton(item: item),
                      const SizedBox(width: 6),
                      _AssignedHomeworkEditButton(onTap: onEdit),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _onlineClassAccent, size: 16),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppFontFamily.forText(label),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
          ),
        ),
      ],
    );
  }

  Widget get _submissionChip {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${item.submitted}/${item.total} ${LocaleKeys.onlineClassSubmitted.tr}',
        style: AppTextStyle.smallPrimaryBold.copyWith(
          color: const Color(0xFF14925A),
        ),
      ),
    );
  }
}

class _AssignedHomeworkEditButton extends StatelessWidget {
  const _AssignedHomeworkEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HomeworkActionButton(
      onTap: onTap,
      icon: Icons.edit_rounded,
      label: LocaleKeys.onlineClassEdit.tr,
      color: _onlineClassAccent,
    );
  }
}

class _AssignedHomeworkDeleteButton extends StatelessWidget {
  const _AssignedHomeworkDeleteButton({required this.item});

  final HomeworkAssignment item;

  @override
  Widget build(BuildContext context) {
    return _HomeworkActionButton(
      onTap: () => _confirmDelete(context),
      icon: Icons.delete_outline_rounded,
      label: LocaleKeys.onlineClassDelete.tr,
      color: const Color(0xFFD80F23),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: Text(LocaleKeys.onlineClassDelete.tr),
                content: Text(LocaleKeys.onlineClassDeleteConfirm.tr),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(LocaleKeys.cancel.tr),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(
                      LocaleKeys.onlineClassDelete.tr,
                      style: const TextStyle(color: Color(0xFFD80F23)),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (!shouldDelete) return;

    try {
      await Get.find<HomeworkController>().deleteAssignment(item.id);
      if (!context.mounted) return;
      Get.snackbar(
        LocaleKeys.onlineClassDelete.tr,
        LocaleKeys.onlineClassDeletedSuccessfully.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }
}

class _HomeworkActionButton extends StatelessWidget {
  const _HomeworkActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyle.smallPrimaryBold.copyWith(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.normalPrimaryBold.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }
}

class _StaticInput extends StatelessWidget {
  const _StaticInput({
    required this.icon,
    required this.label,
    this.minHeight = 48,
    this.controller,
    this.readOnly = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final double minHeight;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lines = minHeight > 60 ? 3 : 1;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _onlineClassBorder),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        minLines: lines,
        maxLines: lines,
        style: AppTextStyle.normalPrimaryRegular,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: AppTextStyle.smallGreyRegular.copyWith(
            color: _homeworkMutedText.withValues(alpha: 0.78),
          ),
          prefixIcon: Container(
            width: 52,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              // color: Color(0xFFFFF7F8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              border: Border(right: BorderSide(color: _onlineClassBorder)),
            ),
            child: Icon(icon, color: _onlineClassAccent, size: 20),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _ClassDropdownField extends StatelessWidget {
  const _ClassDropdownField({
    required this.value,
    required this.options,
    required this.isEnabled,
    required this.onChanged,
  });

  final int? value;
  final List<HomeworkClassOption> options;
  final bool isEnabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <int, HomeworkClassOption>{};
    for (final option in this.options) {
      final id = option.id;
      if (id == null || id <= 0 || option.name.trim().isEmpty) continue;
      options[id] = option;
    }
    final items = options.values.toList(growable: false);
    final selectedValue =
        value != null && options.containsKey(value) ? value : null;

    return DropdownButtonFormField<int>(
      key: ValueKey<int?>(selectedValue),
      initialValue: selectedValue,
      decoration: _fieldDecoration(
        hintText: LocaleKeys.onlineClassSelectClass.tr,
        prefixIcon: Icons.groups_rounded,
      ),
      isExpanded: true,
      dropdownColor: Colors.white,
      items: items
          .map(
            (option) => DropdownMenuItem<int>(
              value: option.id,
              child: Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          )
          .toList(growable: false),
      onChanged:
          items.isEmpty || !isEnabled
              ? null
              : (selected) {
                if (selected != null) onChanged(selected);
              },
      disabledHint: Text(
        items.isEmpty
            ? LocaleKeys.onlineClassNoClassAvailable.tr
            : LocaleKeys.onlineClassSelectClass.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
      prefixIcon: Icon(prefixIcon, color: _onlineClassAccent, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _onlineClassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _onlineClassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _onlineClassAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _DropdownPreview extends StatelessWidget {
  const _DropdownPreview({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _onlineClassAccentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _onlineClassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.class_rounded, color: _onlineClassAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyle.smallGreyRegular),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyle.normalPrimaryBold),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColor.darkGrey,
          ),
        ],
      ),
    );
  }
}

class _DeadlinePickerField extends StatelessWidget {
  const _DeadlinePickerField({required this.controller, required this.onTap});

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _StaticInput(
      icon: Icons.event_rounded,
      label: 'Select deadline',
      controller: controller,
      readOnly: true,
      onTap: onTap,
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: _onlineClassAccent,
        side: const BorderSide(color: _onlineClassBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      ),
    );
  }
}

class _SummaryPair extends StatelessWidget {
  const _SummaryPair({
    required this.leftValue,
    required this.leftLabel,
    required this.rightValue,
    required this.rightLabel,
  });

  final String leftValue;
  final String leftLabel;
  final String rightValue;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MetricBox(value: leftValue, label: leftLabel)),
        const SizedBox(width: 10),
        Expanded(child: _MetricBox(value: rightValue, label: rightLabel)),
      ],
    );
  }
}

class _StudentSubmissionRow extends StatelessWidget {
  const _StudentSubmissionRow({
    required this.homeworkId,
    required this.submission,
    required this.name,
    required this.statusKey,
    required this.onSubmitted,
  });

  final String homeworkId;
  final HomeworkSubmissionStudent submission;
  final String name;
  final String statusKey;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isPending = statusKey == LocaleKeys.onlineClassPending;

    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: _onlineClassAccentSoft,
          child: Text(
            name.characters.first,
            style: AppTextStyle.normalPrimaryBold.copyWith(
              color: _onlineClassWarmRed,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyle.normalPrimarySemiBold),
              const SizedBox(height: 2),
              Text(
                statusKey.tr,
                style: AppTextStyle.smallGreyRegular.copyWith(
                  color: isPending ? _onlineClassWarmRed : AppColor.green,
                  fontWeight: isPending ? FontWeight.w700 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        GetX<HomeworkController>(
          builder: (controller) {
            final isSubmitting = controller.isTeacherSubmittingForStudent(
              submission.id,
            );
            if (!isPending) {
              return TextButton(
                onPressed: () {},
                child: Text(
                  LocaleKeys.onlineClassView.tr,
                  style: AppTextStyle.smallPrimaryBold.copyWith(
                    color: _onlineClassAccent,
                  ),
                ),
              );
            }

            return TextButton(
              onPressed:
                  isSubmitting
                      ? null
                      : () async {
                        try {
                          await controller.submitHomeworkForStudent(
                            homeworkId: homeworkId,
                            student: submission,
                          );
                          await controller.fetchTeacherHomeworks();
                          onSubmitted();
                          Get.snackbar(
                            LocaleKeys.onlineClassSuccessTitle.tr,
                            'Homework submitted for $name',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          ExceptionHandler.handleException(e);
                        }
                      },
              child:
                  isSubmitting
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
                        LocaleKeys.submit.tr,
                        style: AppTextStyle.smallPrimaryBold.copyWith(
                          color: _onlineClassAccent,
                        ),
                      ),
            );
          },
        ),
      ],
    );
  }
}
