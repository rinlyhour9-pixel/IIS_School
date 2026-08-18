import 'package:flutter/material.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/requestleave/model.dart';

String requestLeaveStatusOf(RequestLeaveModel model) {
  final raw = (model.status ?? '').toLowerCase().trim();
  if (raw.contains('pending') || raw == '0' || raw.contains('wait')) {
    return 'pending';
  }
  if (raw.contains('approve') || raw == '1') {
    return 'approved';
  }
  if (raw.contains('reject') || raw == '2' || raw.contains('deny')) {
    return 'rejected';
  }
  return raw;
}

AppStatusStyle requestLeaveStatusStyle(String status) {
  return AppStatusStyles.leave(status);
}

Color requestLeaveStatusColor(String status) {
  return requestLeaveStatusStyle(status).color;
}

Color requestLeaveStatusBackground(String status) {
  return requestLeaveStatusStyle(status).background;
}

String requestLeaveStatusLabel(String status) {
  return requestLeaveStatusStyle(status).label;
}
