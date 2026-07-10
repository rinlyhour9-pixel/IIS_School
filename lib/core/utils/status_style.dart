import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/resources/locales.g.dart';

class AppStatusStyle {
  const AppStatusStyle({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;
}

class AppStatusStyles {
  AppStatusStyles._();

  static AppStatusStyle leave(String status) {
    final value = status.trim().toLowerCase();
    if (value == 'approved') {
      return AppStatusStyle(
        label: LocaleKeys.approved.tr,
        color: const Color(0xFF2E7D32),
        background: const Color(0xFFE8F5E9),
      );
    }
    if (value == 'rejected') {
      return AppStatusStyle(
        label: LocaleKeys.rejected.tr,
        color: const Color(0xFFC62828),
        background: const Color(0xFFFFEBEE),
      );
    }
    return AppStatusStyle(
      label: LocaleKeys.pending.tr,
      color: const Color(0xFFB7791F),
      background: const Color(0xFFFFF7E6),
    );
  }

  static AppStatusStyle attendance(String status) {
    final value = status.trim().toLowerCase();
    if (value.contains('permission')) {
      return AppStatusStyle(
        label: LocaleKeys.permission.tr,
        color: Colors.blue,
        background: Colors.blue.shade50,
      );
    }
    if (value.contains('late')) {
      return AppStatusStyle(
        label: LocaleKeys.late.tr,
        color: Colors.orange,
        background: Colors.orange.shade50,
      );
    }
    if (value.contains('absent')) {
      return AppStatusStyle(
        label: LocaleKeys.absent.tr,
        color: Colors.red,
        background: Colors.red.shade50,
      );
    }
    return AppStatusStyle(
      label: LocaleKeys.present.tr,
      color: const Color(0xFF4CAF50),
      background: const Color(0xFFE8F5E9),
    );
  }
}
