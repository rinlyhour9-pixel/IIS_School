import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/schedule/schedule.dart';
import 'package:schoolapp/views/schedule/controller.dart';

class ScheduleCardWidget extends StatefulWidget {
  const ScheduleCardWidget({super.key});

  @override
  State<ScheduleCardWidget> createState() => _ScheduleCardWidgetState();
}

class _ScheduleCardWidgetState extends State<ScheduleCardWidget> {
  final TransformationController _transformationController =
      TransformationController();

  double _minScale = 1.0;
  static const double _maxScale = 1.2 * 1.2;

  static const double _timeColWidth = 78;
  static const double _teacherColWidth = 110;
  static const double _taColWidth = 60;
  static const double _dayColWidth = 96;
  static const double _rowHeight = 56;
  static const double _headerHeight = 40;

  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.001) {
      setState(() => _currentScale = scale);
    }
  }

  void _zoomBy(double factor) {
    final target = (_currentScale * factor).clamp(_minScale, _maxScale);
    if (target == _currentScale) return;
    final scaleChange = target / _currentScale;
    final newMatrix =
        _transformationController.value.clone()..scale(scaleChange);
    _transformationController.value = newMatrix;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value.isNotEmpty) {
        return NoDataWidget(text: controller.error.value);
      }

      final timetable = controller.timetable.value;
      if (timetable == null || timetable.info.periods.isEmpty) {
        return const NoDataWidget();
      }

      final info = timetable.info;
      final hasTa = info.periods.any((p) => p.ta.trim().isNotEmpty);
      final totalWidth =
          _timeColWidth +
          _teacherColWidth +
          (hasTa ? _taColWidth : 0) +
          (_dayColWidth * info.days.length);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${LocaleKeys.classLabel.tr}: ${timetable.className}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  info.date,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, viewportConstraints) {
                final fitScale =
                    totalWidth > 0
                        ? (viewportConstraints.maxWidth / totalWidth).clamp(
                          0.1,
                          1.0,
                        )
                        : 1.0;
                if ((fitScale - _minScale).abs() > 0.001) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _minScale = fitScale);
                  });
                }

                return Stack(
                  children: [
                    InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: _minScale,
                      maxScale: _maxScale,
                      constrained: false,
                      boundaryMargin: EdgeInsets.zero,
                      child: SizedBox(
                        width: totalWidth,
                        child: Column(
                          children: [
                            _buildInfoHeader(info),
                            _buildHeaderRow(info, hasTa),
                            ...info.periods.map(
                              (p) =>
                                  _buildPeriodRow(p, info.days.length, hasTa),
                            ),
                            if (info.notesEn.isNotEmpty ||
                                info.notesCn.isNotEmpty)
                              _buildNotes(info),
                            if (info.footerNote.isNotEmpty) _buildFooter(info),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'schedule_zoom_in',
                            backgroundColor:
                                _currentScale >= _maxScale ? Colors.grey : null,
                            onPressed:
                                _currentScale >= _maxScale
                                    ? null
                                    : () => _zoomBy(1.2),
                            child: const Icon(Icons.add),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'schedule_zoom_out',
                            backgroundColor:
                                _currentScale <= _minScale ? Colors.grey : null,
                            onPressed:
                                _currentScale <= _minScale
                                    ? null
                                    : () => _zoomBy(1 / 1.2),
                            child: const Icon(Icons.remove),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'schedule_zoom_reset',
                            onPressed: _resetZoom,
                            child: const Icon(Icons.center_focus_strong),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInfoHeader(ScheduleInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              info.title,
              info.academicYear,
            ].where((e) => e.isNotEmpty).join(' '),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (info.branch.isNotEmpty)
            Text(
              'Branch: ${info.branch}',
              style: const TextStyle(fontSize: 11),
            ),
          if (info.address.isNotEmpty)
            Text(
              info.address,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          Wrap(
            spacing: 12,
            children: [
              if (info.tel.isNotEmpty)
                Text('Tel: ${info.tel}', style: const TextStyle(fontSize: 11)),
              if (info.email.isNotEmpty)
                Text(info.email, style: const TextStyle(fontSize: 11)),
              if (info.website.isNotEmpty)
                Text(info.website, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(ScheduleInfo info, bool hasTa) {
    return Container(
      height: _headerHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFDCEBFA),
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          _headerCell(LocaleKeys.timeLabel.tr, _timeColWidth),
          _headerCell(LocaleKeys.teacherLabel.tr, _teacherColWidth),
          if (hasTa) _headerCell(LocaleKeys.taLabel.tr, _taColWidth),
          ...info.days.map((d) => _headerCell(d, _dayColWidth)),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black12)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPeriodRow(SchedulePeriod period, int dayCount, bool hasTa) {
    if (period.isBreak) {
      return Container(
        constraints: const BoxConstraints(minHeight: _rowHeight),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F4F7),
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _timeCell(period),
              Expanded(
                child: Center(
                  child: Text(
                    period.label.isEmpty ? '-' : period.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _timeCell(period),
            _bodyCell(
              width: _teacherColWidth,
              child: Text(
                period.teacher.isEmpty ? '-' : period.teacher,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            if (hasTa)
              _bodyCell(
                width: _taColWidth,
                child: Text(
                  period.ta.isEmpty ? '-' : period.ta,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ...List.generate(dayCount, (i) {
              final cell = i < period.cells.length ? period.cells[i] : null;
              return _bodyCell(
                width: _dayColWidth,
                child:
                    cell == null
                        ? const SizedBox.shrink()
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cell.subject,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (cell.detail.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                cell.detail,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _timeCell(SchedulePeriod period) {
    return _bodyCell(
      width: _timeColWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            period.am,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            period.pm,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _bodyCell({required double width, required Widget child}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black12)),
      ),
      child: child,
    );
  }

  Widget _buildNotes(ScheduleInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.noticesLabel.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          if (info.notesEn.isNotEmpty)
            Text(info.notesEn, style: const TextStyle(fontSize: 11)),
          if (info.notesCn.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(info.notesCn, style: const TextStyle(fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(ScheduleInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Text(
        info.footerNote,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
