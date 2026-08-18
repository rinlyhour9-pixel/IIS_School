import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:schoolapp/models/parent/parent.dart' as parent_model;
import 'package:schoolapp/views/student_information/controller.dart';

class ParentProfileWidget extends GetView<StudentInformationController> {
  const ParentProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final parent = controller.parentInfo.value;
        if (controller.isLoading.value && parent == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (parent == null) {
          return Center(child: Text(LocaleKeys.noParentInformationFound.tr));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          children: [
            Center(
              child: Container(
                width: 184,
                height: 184,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF006E6D), width: 6),
                ),
                child: ClipOval(child: _buildImage(parent)),
              ),
            ),
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
                  _infoRow(LocaleKeys.studentId.tr, _safe(parent.id?.toString())),
                  _infoRow(LocaleKeys.parent.tr, _safe(parent.name)),
                  _infoRow(LocaleKeys.profession.tr, _safe(parent.occupation)),
                  _infoRow(LocaleKeys.phoneNumber.tr, _safe(parent.phone)),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildImage(parent_model.Parent parent) {
    final url = (parent.profile ?? '').trim();
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _resolve(url),
        fit: BoxFit.cover,
        httpHeaders: _headers(),
        placeholder:
            (_, __) => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget:
            (_, __, ___) =>
                Image.asset('assets/images/studentprofile.jpg', fit: BoxFit.cover),
      );
    }
    return Image.asset('assets/images/studentprofile.jpg', fit: BoxFit.cover);
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  String _safe(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? 'N/A' : text;
  }

  String _resolve(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final base = AppConfig.shared.baseUrl.trim();
    if (base.isEmpty) return value;
    final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    return baseUri
        .resolve(value.startsWith('/') ? value.substring(1) : value)
        .toString();
  }

  Map<String, String>? _headers() {
    final token = AppConfig.shared.authorizationToken.trim();
    if (token.isEmpty) return null;
    return <String, String>{'Authorization': token};
  }
}
