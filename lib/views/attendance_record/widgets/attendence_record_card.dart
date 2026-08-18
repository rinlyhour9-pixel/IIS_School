import 'package:cached_network_image/cached_network_image.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/flavor.dart';
import 'package:schoolapp/models/staff/model.dart';
import 'package:schoolapp/views/attendance_record/controller.dart';
import 'package:schoolapp/views/start/controller.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendenceRecordCardWidget extends StatefulWidget {
  const AttendenceRecordCardWidget({super.key});

  @override
  State<AttendenceRecordCardWidget> createState() =>
      _AttendenceRecordCardWidgetState();
}

class _AttendenceRecordCardWidgetState
    extends State<AttendenceRecordCardWidget> {
  final controller = Get.find<AttendanceRecordController>();
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: CustomIndicator(progress: 1 / 4),
          ),
          10.height,
          Obx(
            () =>
                controller.selectedStatus.value.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Showing: ${_statusText(controller.selectedStatus.value)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: controller.clearStatusFilter,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
          ),
          10.height,
          Obx(
            () => GestureDetector(
              onTap: () => controller.pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.selectedDate.value.isEmpty
                            ? LocaleKeys.allDates.tr
                            : controller.selectedDate.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (controller.selectedDate.value.isNotEmpty)
                      GestureDetector(
                        onTap: controller.clearDateFilter,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.close, size: 18),
                        ),
                      ),
                    const Icon(Icons.calendar_month_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
          20.height,
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.attendanceList.isEmpty) {
              final emptyMessage =
                  controller.isParentMode
                      ? LocaleKeys.noAttendanceLogsFound.tr
                      : LocaleKeys.noStaffAttendanceLogsFound.tr;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  emptyMessage,
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }

            return Column(
              children:
                  controller.attendanceList.map((item) {
                    return _buildCard(item);
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCard(StaffAttendanceItem item) {
    final staffId =
        item.staffCode.isNotEmpty ? item.staffCode.trim() : item.id.trim();
    final profileUrl = _sharedProfileUrl(item.profile);
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.translate(
                offset: const Offset(-50, -30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.attendanceDate,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(profileUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (staffId.isNotEmpty)
                          Text(
                            'ID: $staffId',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    height: 30,
                    width: 70,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _statusColor(item.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _statusText(item.status),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                          fontFamily: AppFontFamily.forText(
                            _statusText(item.status),
                          ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      style: AppTextStyle.timeformatText,
                      '${LocaleKeys.morningIn.tr}: ${_timeText(item.timeIn1)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      style: AppTextStyle.timeformatText,
                      '${LocaleKeys.morningOut.tr} | ${_timeText(item.timeOut1)}',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      style: AppTextStyle.timeformatText,
                      '${LocaleKeys.afternoonIn.tr}: ${_timeText(item.timeIn2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      style: AppTextStyle.timeformatText,
                      '${LocaleKeys.afternoonOut.tr} | ${_timeText(item.timeOut2)}',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String rawStatus) {
    return AppStatusStyles.attendance(rawStatus).color;
  }

  String _statusText(String rawStatus) {
    return AppStatusStyles.attendance(rawStatus).label;
  }

  String _timeText(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == '-') {
      return 'N/A';
    }

    final formatted = _formatToAmPm(normalized);
    return formatted ?? normalized;
  }

  String? _formatToAmPm(String value) {
    final formatters = <DateFormat>[
      DateFormat('HH:mm:ss'),
      DateFormat('HH:mm'),
      DateFormat('H:mm:ss'),
      DateFormat('H:mm'),
      DateFormat('hh:mm a'),
      DateFormat('h:mm a'),
    ];

    for (final formatter in formatters) {
      try {
        final dateTime = formatter.parseStrict(value);
        return DateFormat('hh:mm:ss a').format(dateTime);
      } catch (_) {}
    }

    return null;
  }

  Widget _buildAvatar(String profileUrl) {
    const double size = 36;
    final resolvedUrl = _resolveProfileUrl(profileUrl);
    if (resolvedUrl.isEmpty) {
      return _avatarPlaceholder(size);
    }

    return _buildImageAvatar(resolvedUrl, size);
  }

  String _sharedProfileUrl(String fallbackProfile) {
    try {
      if (Get.isRegistered<StartController>()) {
        final appBarUrl = Get.find<StartController>().appBarProfileUrl.trim();
        if (appBarUrl.isNotEmpty) {
          return appBarUrl;
        }
      }
    } catch (_) {}
    return fallbackProfile.trim();
  }

  Widget _avatarPlaceholder(double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey.shade200,
      child: Icon(Icons.person, size: size * 0.55, color: Colors.grey.shade600),
    );
  }

  Widget _buildImageAvatar(
    String source,
    double size, {
    Widget Function()? onError,
  }) {
    final errorFallback = onError ?? () => _avatarPlaceholder(size);
    final cacheSize = (size * 3).round();

    if (_isNetworkUrl(source)) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: source,
          width: size,
          height: size,
          fit: BoxFit.cover,
          memCacheWidth: cacheSize,
          memCacheHeight: cacheSize,
          fadeInDuration: const Duration(milliseconds: 120),
          fadeOutDuration: const Duration(milliseconds: 120),
          placeholder: (_, __) => _avatarPlaceholder(size),
          errorWidget: (_, __, ___) => errorFallback(),
        ),
      );
    }

    return ClipOval(
      child: Image.asset(
        source,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => errorFallback(),
      ),
    );
  }

  String _resolveProfileUrl(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty || value.toLowerCase() == 'n/a') {
      return '';
    }
    if (_isNetworkUrl(value) || value.startsWith('assets/')) {
      return value;
    }

    final base = AppConfig.shared.baseUrl.trim();
    if (base.isEmpty) {
      return '';
    }

    final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    return baseUri
        .resolve(value.startsWith('/') ? value.substring(1) : value)
        .toString();
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
