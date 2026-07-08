class EndPoints {
  static String get login => '/api/v1/login';
  static String get profile => '/api/v1/your-profile';
  static String get dashboard => '/api/v1/dashboard';
  static String get payment => '/api/v1/payment';
  static String get paymentDetail => '/api/v1/payment-details';
  static String get customerPaymentDetail => '/api/v1/customer/payment';
  static String get updateProfile => '/api/v1/your-profile';
  static String get scanCard => '/api/v1/student/staff/scan-card';
  static String get attendanceRecord => '/api/v1/attendance-log/list';
  static String get parentChildrenAttendanceLog =>
      '/api/v1/attendance-log/parent/children-log';
  static String get attendanceSummary => '/api/v1/parent/attendance-summary';
  static String get parentProfile => '/api/v1/parent/profile';
  static String get parentStudentInfo => '/api/v1/parent/student-info';
  static String get parentLeaveRequests => '/api/v1/parent/leave-requests';

  // static String get sampleBooking => 'customer/booking-listing';
  // static String get createBooking => 'customer/booking';
  // static String get zone => 'customer/zone-listing';
  //static String get bookingDetails => 'customer/booking';

  static String get contactUs => '/api/v1/support';
  static String get tracking => '/api/v1/student/attendance/trackings';
  static String get studentTimeSheet => '/api/v1/time-sheet/parent';
  static String get teacherTimeSheet => '/api/v1/time-sheet/teacher';
  static String get sliders => '/api/v1/setting/sliders';
  static String get generalSetting => '/api/v1/setting/general';
  static String get announcements => '/api/v1/setting/announcement';
  static String get classes => '/api/v1/setting/classes';
  static String get classActivities => '/api/v1/setting/class/activities';

  static String get sections => '/api/v1/setting/sections';
  static String get studentAttendanceHistory =>
      '/api/v1/teacher/student/attendance';
  static String get subjects => '/api/v1/setting/subjects';
  static String get studentAttendanceList =>
      '/api/v1/teacher/student/attendance/list';
  static String get studentAttendanceRecord =>
      '/api/v1/teacher/student/attendance/record';
  static const String studentAttendanceDetails =
      '/api/v1/teacher/student/attendance/details';
  static const String leaveList = '/api/v1/teacher/view/student-req-leave';
  static String leaveDetail(int id) =>
      '/api/v1/teacher/view/student-req-leave/$id';
  static String classActivitiesByClass(dynamic classId) =>
      '/api/v1/setting/class/activities/$classId';
  static String get registerFcmToken => '/api/v1/notifications/fcm-token';
  static String teacherDashboard(dynamic teacherId) =>
      '/api/v1/teacher/dashboard/$teacherId';
  static String get teacherHomeworks => '/api/v1/teacher/homeworks';
  static String get teacherActivities => '/api/v1/teacher/activities';
  static String get teacherClassActivity => '/api/v1/teacher/class-activity';
  static String teacherClassActivityUpdate(dynamic id) =>
      '/api/v1/teacher/class-activity/update/$id';
  static String teacherClassActivityDelete(dynamic id) =>
      '/api/v1/teacher/class-activity/delete/$id';
  static String teacherHomeworkDetail(dynamic id) =>
      '/api/v1/teacher/homeworks/$id';
  static String teacherHomeworkDelete(dynamic id) =>
      '/api/v1/teacher/homeworks/$id/delete';
  static String get teacherSubmitHomework => '/api/v1/teacher/submit/homework';
  static String studentHomeworks(dynamic classId) =>
      '/api/v1/student/homeworks/$classId';
  static String get studentHomeworkSubmit => '/api/v1/student/homework/submit';
  static String parentLeaveRequest(dynamic studentId) =>
      '/api/v1/parent/$studentId/leave-request';
  static String paymentHistory(int studentId) =>
      '/api/v1/parent/payment-history/$studentId';
  static String parentInvoiceDetails(int id) =>
      '/api/v1/parent/$id/invoice/details';
  static String classActivityDetails(int id) =>
      '/api/v1/setting/class/activities/$id/details';
  static String announcementDetails(int id) =>
      '/api/v1/setting/announcement/$id/details';
  static String get deleteAccount => '/api/v1/disable-user';
  static String get studentScanCard => '/api/v1/student/scan-card';
}
