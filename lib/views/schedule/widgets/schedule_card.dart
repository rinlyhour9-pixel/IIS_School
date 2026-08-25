import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:schoolapp/models/schedule/schedule.dart';
import 'package:schoolapp/views/schedule/controller.dart';
import 'package:share_plus/share_plus.dart';

class ScheduleCardWidget extends StatefulWidget {
  const ScheduleCardWidget({super.key});

  @override
  State<ScheduleCardWidget> createState() => _ScheduleCardWidgetState();
}

class _DownloadProgressState {
  _DownloadProgressState({required this.message});

  final ValueNotifier<double> value = ValueNotifier<double>(0.08);

  String message;
  bool isCanceled = false;
  bool _isOpen = true;

  void update(double nextValue, String nextMessage) {
    if (isCanceled) return;

    message = nextMessage;
    value.value = nextValue.clamp(0, 1).toDouble();
  }

  void cancel() {
    isCanceled = true;
    close();
  }

  void close() {
    if (!_isOpen) return;

    _isOpen = false;
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

class _ScheduleCardWidgetState extends State<ScheduleCardWidget> {
  final TransformationController _transformationController =
      TransformationController();
  GlobalKey _downloadBoundaryKey = GlobalKey();

  double _minScale = 1.0;
  static const double _maxScale = 1.2 * 1.2;

  static const double _timeColWidth = 120;
  static const double _teacherColWidth = 120;
  static const double _taColWidth = 120;
  static const double _dayColWidth = 120;
  static const double _rowHeight = 56;
  static const double _breakRowHeight = 40;
  static const double _headerHeight = 40;
  static const double _khmerTimeColWidth = 96;
  static const double _khmerTeacherColWidth = 145;
  static const double _khmerDayColWidth = 96;
  static const double _khmerHeaderHeight = 58;
  static const double _khmerLessonRowHeight = 38;
  static const double _khmerActivityRowHeight = 32;

  double _currentScale = 1.0;
  bool _hasAppliedFitScale = false;
  bool _isApplyingScaleSilently = false;
  String? _visibleScheduleKey;
  String? _downloadBoundaryKeyTag;
  double _tabSwipeDistance = 0;
  int _lastSelectedScheduleIndex = 0;
  int _scheduleTabDirection = 1;

  bool get _isKhmerLanguage =>
      AppConfig.shared.language.toUpperCase().startsWith('KM') ||
      Get.locale?.languageCode.toUpperCase().startsWith('KM') == true;

  String _downloadText(String en, String km) => _isKhmerLanguage ? km : en;

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
    if (_isApplyingScaleSilently) return;

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
        _transformationController.value.clone()
          ..multiply(Matrix4.diagonal3Values(scaleChange, scaleChange, 1));
    _transformationController.value = newMatrix;
  }

  void _resetZoom() {
    _setZoomScale(_minScale);
  }

  void _setZoomScale(double scale) {
    _transformationController.value = Matrix4.diagonal3Values(scale, scale, 1);
  }

  void _setZoomScaleSilently(double scale) {
    _isApplyingScaleSilently = true;
    _transformationController.value = Matrix4.diagonal3Values(scale, scale, 1);
    _isApplyingScaleSilently = false;
  }

  void _applyFitScale(double fitScale) {
    if ((fitScale - _minScale).abs() <= 0.001 && _hasAppliedFitScale) {
      return;
    }

    final wasAtMinimum =
        _currentScale <= _minScale + 0.001 || !_hasAppliedFitScale;
    _minScale = fitScale;
    _hasAppliedFitScale = true;

    if (wasAtMinimum) {
      _currentScale = fitScale;
      _setZoomScaleSilently(fitScale);
    }
  }

  bool get _isZoomedIn => _currentScale > _minScale + 0.001;

  void _handleTabSwipeEnd(ScheduleController controller) {
    if (controller.timetables.length <= 1 || _isZoomedIn) {
      _tabSwipeDistance = 0;
      return;
    }

    final current = controller.selectedIndex.value;
    final lastIndex = controller.timetables.length - 1;
    const threshold = 48.0;

    if (_tabSwipeDistance <= -threshold && current < lastIndex) {
      controller.selectTimetable(current + 1);
    } else if (_tabSwipeDistance >= threshold && current > 0) {
      controller.selectTimetable(current - 1);
    }

    _tabSwipeDistance = 0;
  }

  void _syncVisibleSchedule(ScheduleTimetable timetable, int index) {
    final scheduleKey =
        '${index}_${timetable.programName}_${timetable.className}';
    if (_visibleScheduleKey == scheduleKey) return;

    _scheduleTabDirection = index >= _lastSelectedScheduleIndex ? 1 : -1;
    _lastSelectedScheduleIndex = index;
    _visibleScheduleKey = scheduleKey;
    if (_downloadBoundaryKeyTag != scheduleKey) {
      _downloadBoundaryKey = GlobalKey();
      _downloadBoundaryKeyTag = scheduleKey;
    }
    _hasAppliedFitScale = false;
  }

  Future<void> _downloadSchedulePhoto() async {
    final pixelRatio =
        MediaQuery.devicePixelRatioOf(context).clamp(3.0, 4.0).toDouble();
    final progress = _DownloadProgressState(
      message: _downloadText('Starting download', 'កំពុងចាប់ផ្តើមទាញយក'),
    );
    _showDownloadProgressDialog(progress);

    try {
      final boundary =
          _downloadBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        progress.close();
        _showDownloadError();
        return;
      }

      progress.update(
        0.18,
        _downloadText('Preparing photo', 'កំពុងរៀបចំរូបភាព'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (progress.isCanceled) return;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      progress.update(
        0.42,
        _downloadText('Capturing schedule', 'កំពុងថតកាលវិភាគ'),
      );
      if (progress.isCanceled) return;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        progress.close();
        _showDownloadError();
        return;
      }

      final imageBytes = byteData.buffer.asUint8List();
      progress.update(
        0.82,
        _downloadText('Saving photo', 'កំពុងរក្សាទុករូបភាព'),
      );
      if (progress.isCanceled) return;

      final timestamp = _fileTimestamp();
      final photoFile = await _saveScheduleFile(
        bytes: imageBytes,
        fileName: 'schedule_$timestamp.png',
      );
      progress.update(1, _downloadText('Complete', 'រួចរាល់'));
      await Future<void>.delayed(const Duration(milliseconds: 180));
      progress.close();
      _showDownloadSuccessDialog(photoFile, imageBytes);
    } catch (e) {
      debugPrint('Failed to download schedule: $e');
      progress.close();
      _showDownloadError();
    }
  }

  void _showDownloadProgressDialog(_DownloadProgressState progress) {
    DialogManager.showCustom(
      Dialog(
        elevation: 0,
        backgroundColor: AppColor.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: ValueListenableBuilder<double>(
          valueListenable: progress.value,
          builder: (context, value, _) {
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primaryColor.withValues(alpha: 0.08),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: AppColor.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _downloadText(
                            'Saving schedule',
                            'កំពុងរក្សាទុកកាលវិភាគ',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColor.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progress.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.primaryText.withValues(alpha: 0.58),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: progress.cancel,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.primaryText.withValues(
                            alpha: 0.72,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.cancel.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showDownloadError() {
    DialogManager.showTopBanner(
      title: LocaleKeys.scheduleTitle.tr,
      message: _downloadText(
        'Unable to download schedule photo. Please try again.',
        'មិនអាចទាញយករូបភាពកាលវិភាគបានទេ។ សូមព្យាយាមម្តងទៀត។',
      ),
      backgroundColor: const Color(0xFFB45309),
    );
  }

  void _showDownloadSuccessDialog(File photoFile, Uint8List previewBytes) {
    DialogManager.showCustom(
      Dialog(
        elevation: 0,
        backgroundColor: AppColor.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColor.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                LocaleKeys.scheduleTitle.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _downloadText(
                  'Schedule photo downloaded successfully.',
                  'បានទាញយករូបភាពកាលវិភាគដោយជោគជ័យ។',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColor.primaryText.withValues(alpha: 0.7),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openSchedulePreview(previewBytes),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: Text(LocaleKeys.view.tr),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        foregroundColor: AppColor.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (buttonContext) {
                        return ElevatedButton.icon(
                          onPressed:
                              () => _shareDownloadedFile(
                                photoFile,
                                'image/png',
                                buttonContext,
                              ),
                          icon: const Icon(Icons.image_outlined, size: 18),
                          label: Text(_downloadText('Share', 'ចែករំលែក')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: AppColor.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(LocaleKeys.cancel.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSchedulePreview(Uint8List previewBytes) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    DialogManager.showCustom(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: AppColor.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ),
            Flexible(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.memory(previewBytes, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareDownloadedFile(
    File file,
    String mimeType,
    BuildContext buttonContext,
  ) async {
    try {
      final box = buttonContext.findRenderObject() as RenderBox?;
      if (!await file.exists()) {
        throw Exception('Downloaded schedule file is missing.');
      }

      await SharePlus.instance.share(
        ShareParams(
          title: LocaleKeys.scheduleTitle.tr,
          files: [
            XFile(
              file.path,
              name: file.uri.pathSegments.last,
              mimeType: mimeType,
            ),
          ],
          sharePositionOrigin:
              box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } catch (e) {
      debugPrint('Failed to share schedule: $e');
      DialogManager.showTopBanner(
        title: LocaleKeys.scheduleTitle.tr,
        message: _downloadText(
          'Unable to share schedule. Please try again.',
          'មិនអាចចែករំលែកកាលវិភាគបានទេ។ សូមព្យាយាមម្តងទៀត។',
        ),
        backgroundColor: const Color(0xFFB45309),
      );
    }
  }

  Future<File> _saveScheduleFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final directories = await _downloadDirectories();
    Object? lastError;

    for (final directory in directories) {
      try {
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final file = File(_joinPath(directory, fileName));
        return file.writeAsBytes(bytes, flush: true);
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? Exception('No writable directory found.');
  }

  Future<List<Directory>> _downloadDirectories() async {
    final directories = <Directory>[];

    if (Platform.isAndroid) {
      directories.add(Directory('/storage/emulated/0/Download'));
    }

    final home = Platform.environment['HOME'];
    if (home != null && home.trim().isNotEmpty) {
      directories.add(Directory(_joinPath(Directory(home), 'Downloads')));
    }

    directories.add(Directory(_joinPath(Directory.systemTemp, 'iis_school')));
    return directories;
  }

  String _joinPath(Directory directory, String name) {
    return '${directory.path}${Platform.pathSeparator}$name';
  }

  String _fileTimestamp() {
    return DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
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

      if (controller.timetables.isEmpty) {
        return const NoDataWidget();
      }

      final selectedIndex =
          controller.selectedIndex.value
              .clamp(0, controller.timetables.length - 1)
              .toInt();
      final timetable = controller.timetables[selectedIndex];
      if (timetable.info.periods.isEmpty) {
        return const NoDataWidget();
      }

      _syncVisibleSchedule(timetable, selectedIndex);

      final info = timetable.info;
      final hasTa =
          !info.isKhmerProgram ||
          info.periods.any((p) => p.ta.trim().isNotEmpty);
      final totalWidth =
          info.isKhmerProgram
              ? 2 +
                  (_khmerTimeColWidth * 2) +
                  _khmerTeacherColWidth +
                  (_khmerDayColWidth * info.days.length)
              : 42 +
                  _timeColWidth +
                  _teacherColWidth +
                  (hasTa ? _taColWidth : 0) +
                  (_dayColWidth * info.days.length);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScheduleTabs(controller),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  tooltip: _downloadText('Download', 'ទាញយក'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  onPressed: _downloadSchedulePhoto,
                  icon: const Icon(
                    Icons.file_download,
                    size: 30,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              // Swiping between class tabs only applies at the fit-to-screen
              // zoom level. Leaving these handlers attached while zoomed in
              // would keep them in the gesture arena fighting
              // InteractiveViewer's own pan recognizer for every horizontal
              // drag, so they're removed outright (not just ignored) once
              // the user has zoomed in.
              onHorizontalDragStart:
                  _isZoomedIn ? null : (_) => _tabSwipeDistance = 0,
              onHorizontalDragUpdate:
                  _isZoomedIn
                      ? null
                      : (details) => _tabSwipeDistance += details.delta.dx,
              onHorizontalDragEnd:
                  _isZoomedIn ? null : (_) => _handleTabSwipeEnd(controller),
              child: LayoutBuilder(
                builder: (context, viewportConstraints) {
                  final fitScale =
                      totalWidth > 0
                          ? (viewportConstraints.maxWidth / totalWidth).clamp(
                            0.1,
                            1.0,
                          )
                          : 1.0;
                  _applyFitScale(fitScale);

                  return Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: Offset(0.06 * _scheduleTabDirection, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: InteractiveViewer(
                          key: ValueKey<String>(_visibleScheduleKey ?? ''),
                          transformationController: _transformationController,
                          minScale: _minScale,
                          maxScale: _maxScale,
                          constrained: false,
                          boundaryMargin: EdgeInsets.zero,
                          child: RepaintBoundary(
                            key: _downloadBoundaryKey,
                            child: ColoredBox(
                              color: Colors.white,
                              child: SizedBox(
                                width: totalWidth,
                                child:
                                    info.isKhmerProgram
                                        ? _buildKhmerSchedule(info)
                                        : _buildEnglishSchedule(info, hasTa),
                              ),
                            ),
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
                                  _currentScale >= _maxScale
                                      ? Colors.grey
                                      : null,
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
                                  _currentScale <= _minScale
                                      ? Colors.grey
                                      : null,
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
          ),
        ],
      );
    });
  }

  Widget _buildScheduleTabs(ScheduleController controller) {
    final timetables = controller.timetables;
    if (timetables.length <= 1) {
      return const SizedBox(height: 8);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.white,
            border: Border.all(color: const Color(0xFFF2993F)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(timetables.length, (index) {
              final item = timetables[index];
              final selected = controller.selectedIndex.value == index;
              final label =
                  item.programName.trim().isNotEmpty
                      ? item.programName.trim()
                      : item.className.trim();

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.selectTimetable(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFF2993F) : AppColor.white,
                    border:
                        index == 0
                            ? null
                            : const Border(
                              left: BorderSide(color: Color(0xFFF2993F)),
                            ),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          selected ? AppColor.white : const Color(0xFFF2993F),
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildEnglishSchedule(ScheduleInfo info, bool hasTa) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Stack(
        children: [
          _buildScheduleWatermark(size: 220),
          Column(
            children: [
              _buildInfoHeader(info),
              _buildHeaderRow(info, hasTa),
              ...info.periods.map(
                (p) => _buildPeriodRow(p, info.days.length, hasTa),
              ),
              if (info.notesEn.isNotEmpty || info.notesCn.isNotEmpty)
                _buildNotes(info),
              if (info.footerNote.isNotEmpty) _buildFooter(info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKhmerSchedule(ScheduleInfo info) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Stack(
        children: [
          _buildScheduleWatermark(size: 230),
          Column(
            children: [
              _buildKhmerInfoHeader(info),
              _buildKhmerTableHeader(info),
              ...info.periods.map(
                (p) => _buildKhmerPeriodRow(p, info.days.length),
              ),
              _buildKhmerFooter(info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleWatermark({required double size}) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Opacity(
            opacity: 0.12,
            child: Image.asset(
              AssetPath.appLogo.path,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKhmerInfoHeader(ScheduleInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildKhmerHeaderLines(info.headerLeft, TextAlign.left),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildKhmerHeaderLines(
                  info.headerRight,
                  TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            info.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0B33B7),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (info.academicYear.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              info.academicYear,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE11D1D),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildKhmerHeaderLines(List<String> lines, TextAlign textAlign) {
    return Column(
      crossAxisAlignment:
          textAlign == TextAlign.right
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children:
          lines
              .map(
                (line) => Text(
                  line,
                  textAlign: textAlign,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildKhmerTableHeader(ScheduleInfo info) {
    return Container(
      height: _khmerHeaderHeight,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black54),
          bottom: BorderSide(color: Colors.black54),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _khmerTimeColWidth * 2,
            child: Column(
              children: [
                Expanded(
                  child: _khmerCell(
                    width: _khmerTimeColWidth * 2,
                    text: 'ម៉ោងសិក្សា',
                    isHeader: true,
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _khmerCell(
                        width: _khmerTimeColWidth,
                        text: 'ពេលព្រឹក',
                        isHeader: true,
                      ),
                      _khmerCell(
                        width: _khmerTimeColWidth,
                        text: 'ពេលរសៀល',
                        isHeader: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _khmerTeacherColWidth,
            child: _khmerCell(
              width: _khmerTeacherColWidth,
              text: 'គ្រូបង្រៀន',
              isHeader: true,
              textColor: const Color(0xFF0B48B7),
            ),
          ),
          ...info.days.map(
            (day) => SizedBox(
              width: _khmerDayColWidth,
              child: _khmerCell(
                width: _khmerDayColWidth,
                text: day,
                isHeader: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKhmerPeriodRow(SchedulePeriod period, int dayCount) {
    final height =
        period.isBreak ? _khmerActivityRowHeight : _khmerLessonRowHeight;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _khmerCell(width: _khmerTimeColWidth, text: period.am),
          _khmerCell(width: _khmerTimeColWidth, text: period.pm),
          if (period.isBreak)
            _khmerCell(
              width: _khmerTeacherColWidth + (_khmerDayColWidth * dayCount),
              text: period.label.isEmpty ? '-' : period.label,
              isHeader: true,
            )
          else ...[
            _khmerCell(
              width: _khmerTeacherColWidth,
              text: period.teacher,
              textColor: const Color(0xFF0B48B7),
              isHeader: true,
            ),
            ...List.generate(dayCount, (index) {
              final cell =
                  index < period.cells.length ? period.cells[index] : null;
              return _khmerCell(
                width: _khmerDayColWidth,
                text: cell?.subject ?? '',
                isHeader: true,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _khmerCell({
    required double width,
    required String text,
    double? height,
    bool isHeader = false,
    Color textColor = Colors.black,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black54),
          bottom: BorderSide(color: Colors.black54),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildKhmerFooter(ScheduleInfo info) {
    if (info.notes.isEmpty &&
        info.dateLine.isEmpty &&
        info.signatures.isEmpty) {
      return const SizedBox.shrink();
    }

    final leftSignature =
        info.signatures.isNotEmpty ? info.signatures.first : null;
    final rightSignature =
        info.signatures.length > 1 ? info.signatures[1] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 72),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      info.notes
                          .map(
                            (note) => Text(
                              '• $note',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  info.dateLine,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(child: _buildKhmerSignature(leftSignature)),
              Expanded(child: _buildKhmerSignature(rightSignature)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKhmerSignature(ScheduleSignature? signature) {
    if (signature == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          signature.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          signature.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildInfoHeader(ScheduleInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AssetPath.appLogo.path,
                width: 42,
                height: 42,
                errorBuilder:
                    (_, __, ___) => const SizedBox(width: 42, height: 42),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  [
                    info.title,
                    info.academicYear,
                  ].where((e) => e.isNotEmpty).join(' '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              if (info.branch.isNotEmpty) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F8EDB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Branch: ${info.branch}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (info.address.isNotEmpty)
                Text(
                  info.address,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (info.tel.isNotEmpty)
                Text('Tel: ${info.tel}', style: const TextStyle(fontSize: 11)),
              if (info.email.isNotEmpty)
                Text(
                  'Email: ${info.email}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1256CC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (info.website.isNotEmpty)
                Text(
                  'Website: ${info.website}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1256CC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4147E),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${LocaleKeys.classLabel.tr}: ${info.className}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              if (info.date.isNotEmpty)
                Text(
                  info.date,
                  style: const TextStyle(
                    color: Color(0xFF1256CC),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
        border: Border(
          top: BorderSide(color: Colors.black54),
          bottom: BorderSide(color: Colors.black54),
        ),
      ),
      child: Row(
        children: [
          _headerCell('Time', _timeColWidth),
          _headerCell('Teacher', _teacherColWidth),
          if (hasTa) _headerCell('TA', _taColWidth),
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
        border: Border(right: BorderSide(color: Colors.black54)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPeriodRow(SchedulePeriod period, int dayCount, bool hasTa) {
    if (period.isBreak) {
      return Container(
        height: period.label == 'Break-Time' ? _breakRowHeight : _rowHeight,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F3F3),
          border: Border(bottom: BorderSide(color: Colors.black54)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _timeCell(period, compact: period.label == 'Break-Time'),
              Expanded(
                child: Center(
                  child: Text(
                    period.label.isEmpty ? '-' : period.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Colors.black,
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
      height: _rowHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black54)),
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
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B48B7),
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
                  period.ta,
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
                                fontWeight: FontWeight.w700,
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

  Widget _timeCell(SchedulePeriod period, {bool compact = false}) {
    final style = TextStyle(
      fontSize: compact ? 9 : 11,
      height: compact ? 1.05 : null,
      fontWeight: FontWeight.w800,
    );

    return _bodyCell(
      width: _timeColWidth,
      verticalPadding: compact ? 2 : 6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(period.am, style: style),
          Text(period.pm, style: style),
        ],
      ),
    );
  }

  Widget _bodyCell({
    required double width,
    required Widget child,
    double verticalPadding = 6,
  }) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: verticalPadding),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black54)),
      ),
      child: child,
    );
  }

  Widget _buildNotes(ScheduleInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info.notesEn.isNotEmpty) ...[
                  const Text(
                    'Notices:',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.notesEn,
                    style: const TextStyle(fontSize: 11, height: 1.3),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            flex: 1,
            child:
                info.notesCn.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        info.notesCn,
                        style: const TextStyle(fontSize: 11, height: 1.3),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ScheduleInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      color: Colors.white,
      child: Text(
        '✎ ${info.footerNote}',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFE11D1D),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
