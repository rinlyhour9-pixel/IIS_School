import 'package:get/get.dart';
import 'package:schoolapp/models/models.dart';

class StudentAttendanceRow {
  final int id;
  final String admissionNo;
  final String studentName;
  final String studentNameKh;
  final String gender;
  final String className;

  final RxBool presence;
  final RxBool late;
  final RxBool absent;
  final RxBool permission;
  final RxString note;

  StudentAttendanceRow({
    required this.id,
    required this.admissionNo,
    required this.studentName,
    required this.studentNameKh,
    required this.gender,
    required this.className,
    required bool presence,
    required bool late,
    required bool absent,
    required bool permission,
    required String note,
  }) : presence = presence.obs,
       late = late.obs,
       absent = absent.obs,
       permission = permission.obs,
       note = note.obs;

  factory StudentAttendanceRow.fromItem(StudentAttendanceItem item) {
    return StudentAttendanceRow(
      id: item.id,
      admissionNo: item.admissionNo,
      studentName: item.studentName,
      studentNameKh: item.studentNameKh,
      gender: item.gender,
      className: item.className,
      presence: item.presence,
      late: item.late,
      absent: item.absent,
      permission: item.permission,
      note: item.note,
    );
  }
}
