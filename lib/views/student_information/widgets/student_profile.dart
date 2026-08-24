import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:schoolapp/models/parent/parent.dart' as parent_model;
import 'package:schoolapp/views/student_information/controller.dart';

class StudentProfileWidget extends GetView<StudentInformationController> {
  const StudentProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final student = controller.selectedStudent.value;
        if (controller.isLoading.value && student == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (student == null) {
          return Center(
            child: Text(
              LocaleKeys.noStudentInformationFound.tr,
              style: const TextStyle(),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          children: [
            Center(child: _avatar(student)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD8D8D8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _infoRow(
                    LocaleKeys.studentId.tr,
                    controller.displayCode(student),
                  ),
                  _infoRow(
                    LocaleKeys.studentName.tr,
                    controller.displayName(student),
                  ),
                  _infoRow(LocaleKeys.dob.tr, controller.displayDob(student)),
<<<<<<< HEAD
                  if (controller.hasPob(student))
                    _infoRow(
                      LocaleKeys.pob.tr,
                      controller.displayPob(student),
                    ),
                  _infoRow(LocaleKeys.sex.tr, controller.displaySex(student)),
                  _infoRow(
                    LocaleKeys.classLabel.tr,
                    controller.displayClassOnly(student),
                  ),
                  _infoRow(
                    LocaleKeys.section.tr,
                    controller.displaySectionOnly(student),
                  ),
                  _infoRow(
                    LocaleKeys.parent.tr,
=======
                  _infoRow(LocaleKeys.pob.tr, controller.displayPob(student)),
                  _infoRow(LocaleKeys.sex.tr, controller.displaySex(student)),
                  _infoRow(
                    LocaleKeys.classSection.tr,
                    controller.displayClass(student),
                  ),
                  _infoRow(
                    LocaleKeys.parentTeacher.tr,
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
                    controller.displayParent(student),
                  ),
                  _infoRow(
                    LocaleKeys.phoneNumber.tr,
                    controller.displayPhone(student),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _avatar(parent_model.Student student) {
    return Container(
      width: 184,
      height: 184,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF006E6D), width: 6),
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openProfilePreview(student),
            child: _buildStudentImage(student),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentImage(parent_model.Student student) {
    final url = _resolveProfileUrl((student.profile ?? '').trim());
    if (url.isEmpty) return _noProfileIcon();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      httpHeaders: _networkHeaders(),
      placeholder:
          (_, __) => Container(
            color: Colors.grey.shade100,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (_, __, ___) => _noProfileIcon(),
    );
  }

  Widget _noProfileIcon() {
    return Container(
      color: const Color(0xFFEFEFEF),
      alignment: Alignment.center,
      child: Icon(Icons.person, size: 90, color: Colors.grey.shade400),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Text(
                  '$label:',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF4B4B4B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xFFE6E6E6),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _safe(String? text) {
    final value = (text ?? '').trim();
    return value.isEmpty ? '-' : value;
  }

  String _resolveProfileUrl(String rawValue) {
    final value = rawValue.trim().replaceAll('\\', '/');
    if (value.isEmpty) return '';

    String normalizePath(String path) {
      return path
          .replaceAll('/uploads/uploads/', '/uploads/')
          .replaceAll('/public/public/', '/public/')
          .replaceAll('/storage/storage/', '/storage/');
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final uri = Uri.tryParse(value);
      if (uri == null) return value;
      return uri.replace(path: normalizePath(uri.path)).toString();
    }
    final base = AppConfig.shared.baseUrl.trim();
    if (base.isEmpty) return '';
    final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    final normalized = normalizePath(value);
    return baseUri
        .resolve(
          normalized.startsWith('/') ? normalized.substring(1) : normalized,
        )
        .toString();
  }

  Map<String, String>? _networkHeaders() {
    final token = AppConfig.shared.authorizationToken.trim();
    if (token.isEmpty) return null;
    return <String, String>{'Authorization': token};
  }

  void _openProfilePreview(parent_model.Student student) {
    final url = _resolveProfileUrl((student.profile ?? '').trim());
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: AspectRatio(
          aspectRatio: 1,
          child:
              url.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    httpHeaders: _networkHeaders(),
                    placeholder:
                        (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    errorWidget: (_, __, ___) => _noProfileIcon(),
                  )
                  : _noProfileIcon(),
        ),
      ),
    );
  }
}
