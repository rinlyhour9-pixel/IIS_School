part of 'homework_widget.dart';

class _ParentHomeworkDashboard extends GetView<HomeworkController> {
  const _ParentHomeworkDashboard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isAssignmentsLoading.value;
      final assignedItems = controller.assignedHomeworkItems.toList(
        growable: false,
      );

      if (isLoading) {
        return const _StudentHomeworkLoadingView();
      }

      if (assignedItems.isEmpty) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: const [_HomeworkDashboardTitle()],
        );
      }

      final totalAssignments = controller.totalAssignments;
      final submittedAssignments = controller.submittedAssignments;
      final pendingAssignments = controller.pendingAssignments;
      final progress = controller.homeworkProgress;
      final progressPercent = (progress * 100).round();

      return DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HomeworkDashboardTitle(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$submittedAssignments/$totalAssignments ${LocaleKeys.onlineClassSubmitted.tr}',
                          style: AppTextStyle.smallGreyRegular.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '$progressPercent%',
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
                      valueColor: const AlwaysStoppedAnimation(
                        _onlineClassAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      //color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _onlineClassBorder),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: _onlineClassAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black87,
                      labelStyle: AppTextStyle.smallPrimaryBold.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: AppTextStyle.smallPrimaryBold
                          .copyWith(fontWeight: FontWeight.w600),
                      tabs: [
                        _HomeworkTabLabel(
                          text: '${LocaleKeys.all.tr} ($totalAssignments)',
                        ),
                        _HomeworkTabLabel(
                          text:
                              '${LocaleKeys.onlineClassPending.tr} ($pendingAssignments)',
                        ),
                        _HomeworkTabLabel(
                          text:
                              '${LocaleKeys.onlineClassSubmitted.tr} ($submittedAssignments)',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  _StudentHomeworkListSection(
                    items: assignedItems,
                  ),
                  _StudentHomeworkListSection(
                    items: controller.pendingHomeworkItems,
                  ),
                  _StudentHomeworkListSection(
                    items: controller.submittedHomeworkItems,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HomeworkDashboardTitle extends StatelessWidget {
  const _HomeworkDashboardTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      LocaleKeys.onlineClassActionAllAssignHomework.tr,
      style: AppTextStyle.largePrimaryBold.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HomeworkTabLabel extends StatelessWidget {
  const _HomeworkTabLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, maxLines: 1, textAlign: TextAlign.center),
      ),
    );
  }
}

class _StudentHomeworkListSection extends StatelessWidget {
  const _StudentHomeworkListSection({required this.items});

  final List<HomeworkAssignment> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _onlineClassBorder),
            ),
            child: Text(
              LocaleKeys.onlineClassNoHomeworkHereYet.tr,
              textAlign: TextAlign.center,
              style: AppTextStyle.smallGreyRegular.copyWith(
                color: _homeworkMutedText,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        return _StudentAssignedHomeworkCard(item: items[index]);
      },
    );
  }
}

class _StudentHomeworkSectionTitle extends StatelessWidget {
  const _StudentHomeworkSectionTitle({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyle.mediumPrimaryBold.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EFF1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: AppTextStyle.smallPrimaryBold.copyWith(
              color: _onlineClassAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentHomeworkLoadingView extends StatelessWidget {
  const _StudentHomeworkLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _onlineClassAccent,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              LocaleKeys.onlineClassLoadingHomework.tr,
              style: AppTextStyle.mediumPrimaryBold.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              LocaleKeys.onlineClassLoadingHomeworkSubtitle.tr,
              textAlign: TextAlign.center,
              style: AppTextStyle.smallGreyRegular.copyWith(
                color: _homeworkMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkAccentCardFrame extends StatelessWidget {
  const _HomeworkAccentCardFrame({
    required this.accentColor,
    required this.child,
    this.stripWidth = 25,
    this.cardOffset = 8,
    this.cardRadius = 18,
    this.shadow = const [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ],
  });

  final Color accentColor;
  final Widget child;
  final double stripWidth;
  final double cardOffset;
  final double cardRadius;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: stripWidth,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(cardRadius + 4),
                  bottomLeft: Radius.circular(cardRadius + 4),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: cardOffset),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: _onlineClassBorder),
              boxShadow: shadow,
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _HomeworkCardTitle extends StatelessWidget {
  const _HomeworkCardTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.largePrimaryBold.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w800,
        fontSize: 16,
        height: 1.25,
      ),
    );
  }
}

class _StudentAssignedHomeworkCard extends StatelessWidget {
  const _StudentAssignedHomeworkCard({required this.item});

  final HomeworkAssignment item;

  @override
  Widget build(BuildContext context) {
    final accentColor = _homeworkAccentFor(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: _HomeworkAccentCardFrame(
        accentColor: accentColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeworkCardTitle(item.title),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.normalPrimaryRegular.copyWith(
                    color: _homeworkMutedText,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _StudentHomeworkInfo(
                icon: Icons.bookmark_rounded,
                label: '${LocaleKeys.classLabel.tr}:',
                text: item.className,
              ),
              const SizedBox(height: 8),
              _StudentHomeworkInfo(
                icon: Icons.calendar_month_rounded,
                label: '${LocaleKeys.onlineClassDeadline.tr}:',
                text: item.deadline,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final controller = Get.find<HomeworkController>();
                  final isSubmitted = controller.isStudentSubmitted(item.id);
                  final isSubmitting = controller.isStudentSubmitting(item.id);

                  return OutlinedButton.icon(
                    onPressed:
                        isSubmitting
                            ? null
                            : () => _openStudentHomeworkSubmitSheet(
                              context,
                              item,
                            ),
                    icon:
                        isSubmitting
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _onlineClassAccent,
                              ),
                            )
                            : Icon(
                              isSubmitted
                                  ? Icons.check_circle_rounded
                                  : Icons.attach_file_rounded,
                              size: 18,
                            ),
                    label: Text(
                      isSubmitting
                          ? LocaleKeys.onlineClassSubmitting.tr
                          : isSubmitted
                          ? LocaleKeys.onlineClassSubmitted.tr
                          : LocaleKeys.onlineClassAttachHomework.tr,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isSubmitted
                              ? const Color(0xFF14925A)
                              : _onlineClassAccent,
                      side: BorderSide(
                        color:
                            isSubmitted
                                ? const Color(0xFFBDE8D1)
                                : _onlineClassAccent,
                      ),
                      backgroundColor:
                          isSubmitted
                              ? const Color(0xFFEFF8F3)
                              : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentHomeworkInfo extends StatelessWidget {
  const _StudentHomeworkInfo({
    required this.icon,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _onlineClassAccent, size: 16),
        const SizedBox(width: 5),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: AppTextStyle.normalPrimaryRegular.copyWith(
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: text,
                  style: AppTextStyle.normalPrimaryRegular.copyWith(
                    color: _homeworkMutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void _openStudentHomeworkSubmitSheet(
  BuildContext context,
  HomeworkAssignment item,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StudentHomeworkSubmitSheet(item: item),
  );
}

void _openHomeworkAttachmentViewer(BuildContext context, String url) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder:
        (_) => Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: CustomNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    fallbackImagePath: AssetPath.placeholder.path,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
  );
}

class _StudentHomeworkSubmitSheet extends StatefulWidget {
  const _StudentHomeworkSubmitSheet({required this.item});

  final HomeworkAssignment item;

  @override
  State<_StudentHomeworkSubmitSheet> createState() =>
      _StudentHomeworkSubmitSheetState();
}

class _StudentHomeworkSubmitSheetState
    extends State<_StudentHomeworkSubmitSheet> {
  final TextEditingController _answerCtl = TextEditingController();
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _answerCtl.addListener(_refreshFormState);
  }

  @override
  void dispose() {
    _answerCtl.removeListener(_refreshFormState);
    _answerCtl.dispose();
    super.dispose();
  }

  void _refreshFormState() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (!mounted || image == null) return;
      setState(() => _selectedImage = image);
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> _submit() async {
    final answer = _answerCtl.text.trim();
    final imagePath = _selectedImage?.path.trim() ?? '';
    if (answer.isEmpty && imagePath.isEmpty) {
      ExceptionHandler.handleException(
        'Please add an answer or attach an image',
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);
      await Get.find<HomeworkController>().submitStudentHomeworkAnswer(
        homeworkId: widget.item.id,
        answerText: answer,
        attachmentPath: imagePath.isEmpty ? null : imagePath,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      Get.snackbar(
        LocaleKeys.onlineClassSuccessTitle.tr,
        LocaleKeys.onlineClassHomeworkSubmittedSuccessfully.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      ExceptionHandler.handleException(e);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasAttachment = _selectedImage != null;
    final hasAnswer = _answerCtl.text.trim().isNotEmpty;
    final canSubmit = hasAttachment || hasAnswer;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFCFD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.onlineClassSubmitHomework.tr,
                            style: AppTextStyle.largePrimaryBold.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            LocaleKeys.onlineClassSubmitHomeworkSubtitle.tr,
                            style: AppTextStyle.smallGreyRegular.copyWith(
                              color: _homeworkMutedText,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _onlineClassAccentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.item.deadline,
                        style: AppTextStyle.smallPrimaryBold.copyWith(
                          color: _onlineClassAccent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF4F6), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _onlineClassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: AppTextStyle.mediumPrimaryBold.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      if (widget.item.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.item.description,
                          style: AppTextStyle.smallGreyRegular.copyWith(
                            color: _homeworkMutedText,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _StudentSubmitMetaChip(
                            icon: Icons.bookmark_rounded,
                            label: widget.item.className,
                          ),
                          _StudentSubmitMetaChip(
                            icon: Icons.calendar_month_rounded,
                            label: widget.item.deadline,
                          ),
                        ],
                      ),
                      if (widget.item.attachmentUrl.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          'Teacher Attachment',
                          style: AppTextStyle.normalPrimaryBold.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap:
                              () => _openHomeworkAttachmentViewer(
                                context,
                                widget.item.attachmentUrl,
                              ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 180,
                                  width: double.infinity,
                                  child: CustomNetworkImage(
                                    imageUrl: widget.item.attachmentUrl,
                                    fit: BoxFit.cover,
                                    fallbackImagePath:
                                        AssetPath.placeholder.path,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x99000000),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Tap to view',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  LocaleKeys.onlineClassYourAnswer.tr,
                  style: AppTextStyle.normalPrimaryBold.copyWith(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _answerCtl,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: LocaleKeys.onlineClassWriteAnswerHint.tr,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _onlineClassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _onlineClassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _onlineClassAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.onlineClassAttachment.tr,
                  style: AppTextStyle.normalPrimaryBold.copyWith(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _isSubmitting ? null : _pickImage,
                  child: Ink(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          hasAttachment
                              ? const Color(0xFFFFF4F6)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            hasAttachment
                                ? _onlineClassAccent
                                : _onlineClassBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _onlineClassAccentSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                hasAttachment
                                    ? Icons.check_circle_rounded
                                    : Icons.add_photo_alternate_outlined,
                                color: _onlineClassAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasAttachment
                                        ? _selectedImage!.name
                                        : LocaleKeys.onlineClassAttachImage.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.normalPrimaryBold
                                        .copyWith(color: Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasAttachment
                                        ? LocaleKeys
                                            .onlineClassImageReadyToUpload
                                            .tr
                                        : LocaleKeys
                                            .onlineClassOptionalChooseImage
                                            .tr,
                                    style: AppTextStyle.smallGreyRegular
                                        .copyWith(
                                          color: _homeworkMutedText,
                                          height: 1.4,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasAttachment)
                              IconButton(
                                onPressed:
                                    _isSubmitting
                                        ? null
                                        : () => setState(
                                          () => _selectedImage = null,
                                        ),
                                icon: const Icon(Icons.close_rounded),
                                color: _homeworkMutedText,
                              ),
                          ],
                        ),
                        if (hasAttachment) ...[
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 152,
                              width: double.infinity,
                              color: const Color(0xFFF6F6F6),
                              child: Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      color: const Color(0xFFF6F6F6),
                                      alignment: Alignment.center,
                                      child: Text(
                                        LocaleKeys
                                            .onlineClassPreviewUnavailable
                                            .tr,
                                        style: AppTextStyle.smallGreyRegular
                                            .copyWith(
                                              color: _homeworkMutedText,
                                            ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _onlineClassBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: _onlineClassAccent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          canSubmit
                              ? '${LocaleKeys.onlineClassReadyToSubmit.tr} ${hasAnswer ? LocaleKeys.onlineClassAddedAnswer.tr : LocaleKeys.onlineClassNoWrittenAnswer.tr}${hasAttachment
                                  ? hasAnswer
                                      ? ' ${LocaleKeys.onlineClassAndImage.tr}'
                                      : ' ${LocaleKeys.onlineClassAndImage.tr}'
                                  : '.'}'
                              : LocaleKeys.onlineClassAddAnswerOrImage.tr,
                          style: AppTextStyle.smallGreyRegular.copyWith(
                            color: _homeworkMutedText,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: _onlineClassBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(LocaleKeys.cancel.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting || !canSubmit ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _onlineClassAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFF2B8BF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(LocaleKeys.onlineClassSubmitHomework.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentSubmitMetaChip extends StatelessWidget {
  const _StudentSubmitMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _onlineClassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _onlineClassAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyle.smallPrimaryBold.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
