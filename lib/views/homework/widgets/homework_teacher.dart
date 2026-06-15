part of 'homework_widget.dart';

class _TeacherHomeworkDashboard extends StatelessWidget {
  const _TeacherHomeworkDashboard();

  static const _actions = [
    _DashboardAction(
      Icons.class_rounded,
      LocaleKeys.onlineClassActionClassDetail,
      LocaleKeys.onlineClassActionViewClassInfo,
    ),
    _DashboardAction(
      Icons.assignment_add,
      LocaleKeys.onlineClassActionAllAssignHomework,
      LocaleKeys.onlineClassActionCreateTask,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        _HeroPanel(
          title: LocaleKeys.onlineClassTeacherWorkbench.tr,
          subtitle: LocaleKeys.onlineClassTeacherWorkbenchSubtitle.tr,
          icon: Icons.school_rounded,
        ),
        const SizedBox(height: 16),
        const _TeacherMetricGrid(),
        const SizedBox(height: 22),
        Row(
          children: [
            Text(
              LocaleKeys.onlineClassTeachingTools.tr,
              style: AppTextStyle.mediumPrimaryBold.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: Row(
            children: [
              Expanded(
                child: _ActionTile(
                  action: _actions[0],
                  onTap:
                      () => _openDetail(
                        context,
                        title: LocaleKeys.onlineClassActionClassDetail.tr,
                        child: const _ClassDetailPanel(),
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionTile(
                  action: _actions[1],
                  onTap: () {
                    final controller = Get.find<HomeworkController>();
                    controller.requestAssignmentsLoading();
                    _openDetail(
                      context,
                      title: LocaleKeys.onlineClassActionAllAssignHomework.tr,
                      child: const _AllAssignedHomeworkPanel(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openDetail(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    Navigator.of(context).push(
      _homeworkRoute(_TeacherActionDetailScreen(title: title, child: child)),
    );
  }
}

class _TeacherMetricGrid extends GetView<HomeworkController> {
  const _TeacherMetricGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dashboard = controller.teacherDashboard.value;
      final isLoading = controller.isTeacherDashboardLoading.value;

      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.9,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _MetricBox(
            icon: Icons.bookmark_rounded,
            value: isLoading ? '...' : '${dashboard?.totalClasses ?? 0}',
            label: LocaleKeys.onlineClassTotalClass.tr,
            accentColor: const Color(0xFFF3B51B),
          ),
          _MetricBox(
            icon: Icons.groups_rounded,
            value: isLoading ? '...' : '${dashboard?.totalStudents ?? 0}',
            label: LocaleKeys.onlineClassStudents.tr,
            accentColor: const Color(0xFF10A850),
          ),
        ],
      );
    });
  }
}

class _TeacherActionDetailScreen extends StatelessWidget {
  const _TeacherActionDetailScreen({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _homeworkPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 5,
                    shadowColor: const Color(0x12000000),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: _onlineClassAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.largePrimaryBold.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [child],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
