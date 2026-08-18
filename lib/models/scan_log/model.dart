class ScanLog {
  final bool success;
  final String message;
  final StaffData? staff;

  ScanLog({required this.success, required this.message, this.staff});

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    return ScanLog(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      staff: json['staff'] != null ? StaffData.fromJson(json['staff']) : null,
    );
  }
}

class StaffData {
  final String name;
  final String scanType;
  final String checkTime;
  final bool isLate;
  final int distance;

  StaffData({
    required this.name,
    required this.scanType,
    required this.checkTime,
    required this.isLate,
    required this.distance,
  });

  factory StaffData.fromJson(Map<String, dynamic> json) {
    return StaffData(
      name: json['name'] ?? 'N/A',
      scanType: json['scan'] ?? 'N/A',
      checkTime: json['check_time'] ?? 'N/A',
      isLate: json['late'] ?? false,
      distance: json['distance'] ?? 0,
    );
  }
}
