import 'dart:io';
import 'dart:typed_data';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/homework/controller.dart';

part 'homework_parent.dart';
part 'homework_shared.dart';
part 'homework_teacher.dart';
part 'homework_teacher_panels.dart';

const Color _onlineClassAccent = Color(0xFFD80F23);
const Color _onlineClassAccentSoft = Color(0xFFFFEEF1);
const Color _onlineClassAccentLight = Colors.white;
const Color _onlineClassBorder = Color(0xFFF0E4E7);
const Color _onlineClassWarmRed = Color(0xFFD80F23);
const Color _homeworkPageBackground = Color(0xFFFFFBFC);
const Color _homeworkMutedText = Color(0xFF6E6E76);
const List<Color> _homeworkAccentPalette = [
  Color(0xFFD80F23),
  Color(0xFF14925A),
  Color(0xFF2F80ED),
  Color(0xFFF2994A),
  Color(0xFF9B51E0),
  Color(0xFF00A6A6),
];

Color _homeworkAccentFor(String seed) {
  final index = seed.hashCode.abs() % _homeworkAccentPalette.length;
  return _homeworkAccentPalette[index];
}

Route<T> _homeworkRoute<T>(Widget child) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class HomeworkWidget extends GetView<HomeworkController> {
  const HomeworkWidget({super.key});

  static void openAssignHomework(BuildContext context) {
    final controller = Get.find<HomeworkController>();

    Navigator.of(context).push(
      _homeworkRoute(
        _TeacherActionDetailScreen(
          title: LocaleKeys.onlineClassActionAssignHomework.tr,
          child: const _AssignHomeworkPanel(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return controller.isParentRole
        ? const _ParentHomeworkDashboard()
        : const _TeacherHomeworkDashboard();
  }
}
