class ScheduleResponse {
  ScheduleResponse({required this.timetables});

  final List<ScheduleTimetable> timetables;

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return ScheduleResponse(
      timetables:
          rawData is List
              ? rawData
                  .whereType<Map>()
                  .map(
                    (e) => ScheduleTimetable.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList()
              : <ScheduleTimetable>[],
    );
  }
}

class ScheduleTimetable {
  ScheduleTimetable({
    required this.programName,
    required this.className,
    required this.isKge,
    required this.info,
  });

  final String programName;
  final String className;
  final bool isKge;
  final ScheduleInfo info;

  factory ScheduleTimetable.fromJson(Map<String, dynamic> json) {
    final rawSchedule = json['schedule'];
    return ScheduleTimetable(
      programName: (json['program_name'] ?? '').toString(),
      className: (json['class_name'] ?? '').toString(),
      isKge: json['is_kge'] == true,
      info: ScheduleInfo.fromJson(
        rawSchedule is Map ? Map<String, dynamic>.from(rawSchedule) : {},
      ),
    );
  }
}

class ScheduleInfo {
  ScheduleInfo({
    required this.title,
    required this.academicYear,
    required this.className,
    required this.branch,
    required this.address,
    required this.tel,
    required this.email,
    required this.website,
    required this.date,
    required this.headerLeft,
    required this.headerRight,
    required this.days,
    required this.periods,
    required this.notesEn,
    required this.notesCn,
    required this.notes,
    required this.dateLine,
    required this.signatures,
    required this.footerNote,
  });

  final String title;
  final String academicYear;
  final String className;
  final String branch;
  final String address;
  final String tel;
  final String email;
  final String website;
  final String date;
  final List<String> headerLeft;
  final List<String> headerRight;
  final List<String> days;
  final List<SchedulePeriod> periods;
  final String notesEn;
  final String notesCn;
  final List<String> notes;
  final String dateLine;
  final List<ScheduleSignature> signatures;
  final String footerNote;

  bool get isKhmerProgram => headerLeft.isNotEmpty || headerRight.isNotEmpty;

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleInfo(
      title: (json['title'] ?? '').toString(),
      academicYear: (json['academic_year'] ?? '').toString(),
      className: (json['class'] ?? '').toString(),
      branch: (json['branch'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      tel: (json['tel'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      website: (json['website'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      headerLeft: _stringList(json['header_left']),
      headerRight: _stringList(json['header_right']),
      days:
          json['days'] is List
              ? List<String>.from(
                (json['days'] as List).map((e) => e.toString()),
              )
              : <String>[],
      periods:
          json['periods'] is List
              ? (json['periods'] as List)
                  .whereType<Map>()
                  .map(
                    (e) =>
                        SchedulePeriod.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : <SchedulePeriod>[],
      notesEn: (json['notes_en'] ?? '').toString(),
      notesCn: (json['notes_cn'] ?? '').toString(),
      notes: _stringList(json['notes']),
      dateLine: (json['date_line'] ?? '').toString(),
      signatures:
          json['signatures'] is List
              ? (json['signatures'] as List)
                  .whereType<Map>()
                  .map(
                    (e) => ScheduleSignature.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList()
              : <ScheduleSignature>[],
      footerNote: (json['footer_note'] ?? '').toString(),
    );
  }

  static List<String> _stringList(Object? raw) {
    return raw is List ? raw.map((e) => e.toString()).toList() : <String>[];
  }
}

class ScheduleSignature {
  ScheduleSignature({required this.title, required this.name});

  final String title;
  final String name;

  factory ScheduleSignature.fromJson(Map<String, dynamic> json) {
    return ScheduleSignature(
      title: (json['title'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class SchedulePeriod {
  SchedulePeriod({
    required this.am,
    required this.pm,
    required this.isBreak,
    required this.label,
    required this.teacher,
    required this.ta,
    required this.cells,
  });

  final String am;
  final String pm;
  final bool isBreak;
  final String label;
  final String teacher;
  final String ta;
  final List<ScheduleCell?> cells;

  factory SchedulePeriod.fromJson(Map<String, dynamic> json) {
    final rawCells = json['cells'];
    final type = (json['type'] ?? '').toString();
    return SchedulePeriod(
      am: (json['am'] ?? '').toString(),
      pm: (json['pm'] ?? '').toString(),
      isBreak: type == 'break' || type == 'activity',
      label: (json['label'] ?? '').toString(),
      teacher: (json['teacher'] ?? '').toString(),
      ta: (json['ta'] ?? '').toString(),
      cells:
          rawCells is List
              ? rawCells
                  .map((e) => ScheduleCell.fromRaw(e?.toString()))
                  .toList()
              : <ScheduleCell?>[],
    );
  }
}

class ScheduleCell {
  ScheduleCell({required this.subject, required this.detail});

  final String subject;
  final String detail;

  static ScheduleCell? fromRaw(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.split('|');
    return ScheduleCell(
      subject: parts.isNotEmpty ? parts[0].trim() : '',
      detail: parts.length > 1 ? parts[1].trim() : '',
    );
  }
}
