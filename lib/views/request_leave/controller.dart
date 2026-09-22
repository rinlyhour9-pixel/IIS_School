import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/child_profile/model.dart';
import 'package:schoolapp/models/models.dart';
import 'package:schoolapp/models/parent/parent.dart';
import 'package:schoolapp/models/requestleave/model.dart';

class RequestLeaveController extends GetxController {
  static const String _pendingCachePrefix = 'pending_leave_requests_';
  static const String _lastLeaveStudentKey = 'last_leave_student_id';
  final TextEditingController searchCtl = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxList<TrackingModel> trackings = <TrackingModel>[].obs;
  final RxList<RequestLeaveModel> requests = <RequestLeaveModel>[].obs;
  final RxString studentIdText = ''.obs;
  final RxString studentNameText = ''.obs;
  final RxString studentGradeText = ''.obs;
  final RxString studentImageUrl = ''.obs;
  final RxBool isLoadingRequests = true.obs;
  final Map<String, Student> _studentsById = <String, Student>{};
  SelectedStudentService get _selectedStudentService =>
      Get.find<SelectedStudentService>();
  bool get isParentMode => UserRepository.shared.isParent;

  bool isDone = false;
  var selectedClass = 'Grade 5'.obs;
  final RxList<String> classOptions = <String>[].obs;
  final RxList<String> selectedClasses = <String>[].obs;
  final RxList<String> sectionOptions = <String>[].obs;
  final RxString selectedSection = ''.obs;
  final Map<String, dynamic> _classIdsByName = <String, dynamic>{};
  final Map<String, dynamic> _sectionIdsByName = <String, dynamic>{};
  final Map<String, _RequestLeaveOption> _sectionByClassName =
      <String, _RequestLeaveOption>{};
  var leaveType = ''.obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var isloading = false.obs;
  final RxString reasonError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(_loadInitialData());
  }

  @override
  void onClose() {
    searchCtl.dispose();
    reasonController.dispose();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    await fetchSelectedStudentInfo();
    if (!isParentMode) {
      isLoadingRequests.value = false;
      return;
    }

    // fetchStudentClasses() triggers the matching section fetch itself
    // (scoped to whichever class it resolves/selects), so it isn't listed
    // alongside a separate unscoped fetchStudentSection() call here.
    await Future.wait(<Future<void>>[fetchStudentClasses(), fetchRequests()]);
  }

  Future<void> pickStartDate() async {
    final context = Get.overlayContext!;

    final DateTime? picked = await showDatePicker(
      context: context,
      builder: (context, child) => _themedDatePicker(context, child),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      startDate.value =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  Future<void> pickEndDate() async {
    final context = Get.overlayContext!;

    final DateTime? picked = await showDatePicker(
      context: context,
      builder: (context, child) => _themedDatePicker(context, child),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      endDate.value =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  Widget _themedDatePicker(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: AppColor.red,
            onPrimary: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColor.red),
          ),
        ),
        child: child!,
      ),
    );
  }

  int get totalDays {
    if (startDate.value.isEmpty || endDate.value.isEmpty) return 0;

    final start = _parseDate(startDate.value);
    final end = _parseDate(endDate.value);

    if (start == null || end == null) return 0;

    // "To" picked before "Leave from" would otherwise make this negative
    // (e.g. -3) instead of a sensible day count — show the span's
    // magnitude regardless of which date was picked first.
    return (end.difference(start).inDays + 1).abs();
  }

  String get _mappedLeaveType {
    final raw = leaveType.value.trim().toLowerCase();
    if (raw == 'sick' || raw == 'ill' || raw == 'illness') {
      return 'Sick';
    }
    if (raw == 'busy' || raw == 'business' || raw == 'personal') {
      return 'Personal';
    }
    if (raw == 'other') {
      return 'Other';
    }
    return 'General';
  }

  Future<void> fetchRequests() async {
    if (!isParentMode) {
      requests.clear();
      isLoadingRequests.value = false;
      return;
    }

    await _ensureStudentLookup();
    final selectedRaw = await _selectedStudentId();
    final selectedResolved = await _resolveStudentIdForRequest(selectedRaw);
    final cacheScopes = _requestCacheScopes(selectedRaw, selectedResolved);

    var cachedPending = <RequestLeaveModel>[];
    isLoadingRequests.value = true;
    try {
      cachedPending = await _loadCachedPendingForScopes(cacheScopes);

      final res = await Get.find<ApiService>().get(
        EndPoints.parentLeaveRequests,
        queryParameters:
            selectedResolved.isNotEmpty
                ? <String, dynamic>{'student_id': selectedResolved}
                : null,
        isShowLoading: false,
      );

      final rows = _filterRowsBySelectedStudent(
        rows: _extractRows(res.data),
        selectedRaw: selectedRaw,
        selectedResolved: selectedResolved,
      );
      final backend =
          rows.map(RequestLeaveModel.fromJson).map(_withStudentInfo).toList();
      final merged = _mergeRequests(backend, cachedPending);
      requests.assignAll(merged);

      // keep only unsynced pending cache items
      final unsynced =
          cachedPending
              .where((p) => !backend.any((b) => _sameRequestKey(b, p)))
              .toList();
      await _saveCachedPendingForScopes(unsynced);
    } catch (e) {
      // Preserve pending items on transient failures.
      final fallback =
          cachedPending.isNotEmpty
              ? cachedPending
              : await _loadCachedPendingForScopes(cacheScopes);
      if (fallback.isNotEmpty) {
        requests.assignAll(fallback);
      }
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> fetchSelectedStudentInfo() async {
    try {
      if (!isParentMode) {
        studentIdText.value =
            (await SharedPreferencesManager.get('staff_code') ?? '')
                .toString()
                .trim();
        studentNameText.value =
            (await SharedPreferencesManager.get('name') ?? '')
                .toString()
                .trim();
        studentGradeText.value = LocaleKeys.teacher.tr;
        studentImageUrl.value =
            (await SharedPreferencesManager.get('profile') ?? '')
                .toString()
                .trim();
        return;
      }

      final selected = _selectedStudentService.current;
      if (selected != null) {
        studentIdText.value = selected.id.trim();
        studentNameText.value = selected.name.trim();
        studentGradeText.value = selected.className.trim();
        studentImageUrl.value = selected.avatar.trim();
        if (selected.className.trim().isNotEmpty) {
          selectedClass.value = selected.className.trim();
        }
      }

      if (_selectedStudentService.children.isNotEmpty) {
        _updateStudentLookupFromProfiles(
          _selectedStudentService.children.toList(growable: false),
        );
      }

      // Refine with the full profile so the displayed Student ID matches the
      // admission code shown on the Student Profile screen, not the raw id.
      final selectedId = await _selectedStudentId();
      final res = await Get.find<ApiService>().get(
        EndPoints.parentStudentInfo,
        isShowLoading: false,
      );
      if (res.data is! Map) {
        return;
      }
      final model = ParentWithChild.fromJson(
        Map<String, dynamic>.from(res.data),
      );
      final students = model.data?.student ?? const <Student>[];
      _updateStudentLookup(students);
      if (students.isEmpty) {
        return;
      }

      Student student = students.first;
      if (selectedId.isNotEmpty) {
        for (final s in students) {
          if ((s.id?.toString() ?? '').trim() == selectedId) {
            student = s;
            break;
          }
        }
      }

      final className = (student.className ?? '').trim();
      studentIdText.value =
          (student.admissionNo ?? student.id?.toString() ?? '').trim();
      studentNameText.value = (student.nameKh ?? student.name ?? '').trim();
      studentGradeText.value = className;
      studentImageUrl.value = (student.profile ?? '').trim();

      if (className.isNotEmpty) {
        selectedClass.value = className;
      }
    } catch (_) {
      // Keep UI stable with existing placeholders.
    }
  }


  Future<void> fetchStudentSection() async {
    if (!isParentMode) {
      return;
    }

    final selectedStudent = await _selectedStudentId();
    if (selectedStudent.isEmpty) {
      return;
    }

    final studentId = await _resolveStudentIdForRequest(selectedStudent);
    if (studentId.isEmpty) {
      return;
    }

    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.parentStudentSection(studentId),
        isShowLoading: false,
      );
      final sectionItems = _extractStudentSectionOptions(res.data);
      _sectionIdsByName
        ..clear()
        ..addEntries(
          sectionItems
              .where((item) => item.id != null)
              .map((item) => MapEntry(item.name, item.id)),
        );
      final sections = sectionItems.map((item) => item.name).toList();
      sectionOptions.assignAll(sections);
      // Section is now auto-derived and read-only in the UI — always take
      // the first option for the newly selected class rather than trying
      // to preserve the previous pick, which could strand a section that
      // doesn't belong to the class just chosen.
      selectedSection.value = sections.isNotEmpty ? sections.first : '';
    } catch (e) {
      ExceptionHandler.handleException(e, alert: false);
    }
  }

  /// Fallback only — see fetchStudentSection's doc comment. Used when the
  /// selected class has no section bundled on its own row.
  Future<void> _refreshSectionsForSelectedClass() async {
    await fetchStudentSection();
  }

  Future<void> fetchStudentClasses() async {
    if (!isParentMode) {
      return;
    }

    final selectedStudent = await _selectedStudentId();
    if (selectedStudent.isEmpty) {
      return;
    }

    final studentId = await _resolveStudentIdForRequest(selectedStudent);
    if (studentId.isEmpty) {
      return;
    }

    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.parentStudentClassSection(studentId),
        isShowLoading: false,
      );
      final classItems = _extractStudentClassSectionOptions(res.data);
      _classIdsByName
        ..clear()
        ..addEntries(
          classItems
              .where((item) => item.id != null)
              .map((item) => MapEntry(item.name, item.id)),
        );
      _sectionByClassName
        ..clear()
        ..addEntries(
          classItems
              .where((item) => (item.sectionName ?? '').isNotEmpty)
              .map((item) => MapEntry(item.name, item)),
        );
      final classes = classItems.map((item) => item.name).toList();
      classOptions.assignAll(classes);
      if (classes.isEmpty) {
        // No linked class to scope sections by — fall back to the
        // unscoped fetch so Section still has something to show.
        await _refreshSectionsForSelectedClass();
        return;
      }

      final current = studentGradeText.value.trim();
      final selected =
          classes.firstWhereOrNull((item) => item.trim() == current) ??
          classes.first;
      // setSelectedClasses triggers the section refresh for `selected`.
      setSelectedClasses(<String>[selected]);
    } catch (e) {
      ExceptionHandler.handleException(e, alert: false);
    }
  }

  void setSelectedClasses(List<String> classes) {
    final seen = <String>{};
    final cleaned =
        classes.map((item) => item.trim()).where((item) {
          if (item.isEmpty || item.toLowerCase() == 'null') {
            return false;
          }
          return seen.add(item.toLowerCase());
        }).toList();
    selectedClasses.assignAll(cleaned);
    final text = cleaned.join(', ');
    selectedClass.value = text;
    studentGradeText.value = text;

    // Prefer the section bundled directly on the selected class's own row
    // (authoritative — see _extractStudentClassSectionOptions) over the
    // separate /parent/student-section/{id} fetch, which is a flat,
    // generic reference list with no class awareness at all.
    final bundled =
        cleaned.length == 1 ? _sectionByClassName[cleaned.first] : null;
    if (bundled != null) {
      sectionOptions.assignAll(<String>[bundled.sectionName!]);
      selectedSection.value = bundled.sectionName!;
      if (bundled.sectionId != null) {
        _sectionIdsByName
          ..clear()
          ..[bundled.sectionName!] = bundled.sectionId;
      }
      return;
    }

    unawaited(_refreshSectionsForSelectedClass());
  }

  Future<RequestLeaveModel?> submitRequest() async {
    if (!isParentMode) {
      Get.snackbar(
        LocaleKeys.error.tr,
        'Teacher leave request is not configured in this app yet.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      reasonError.value = LocaleKeys.cannotBeEmpty.tr;
      Get.snackbar(
        LocaleKeys.error.tr,
        '${LocaleKeys.reason.tr} ${LocaleKeys.cannotBeEmpty.tr}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
    reasonError.value = '';

    if (startDate.value.isEmpty || endDate.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please complete all required fields.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }

    final selectedStudent = await _selectedStudentId();
    if (selectedStudent.isEmpty) {
      Get.snackbar(
        'Error',
        'No selected student.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
    final studentId = await _resolveStudentIdForRequest(selectedStudent);
    if (studentId.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid selected student.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
    await SharedPreferencesManager.setValue(_lastLeaveStudentKey, studentId);

    final selectedClassIds = _selectedClassIds();
    if (selectedClassIds.isEmpty) {
      Get.snackbar(
        'Error',
        'No selected class.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
    final selectedSectionId = _selectedSectionId();

    isloading.value = true;
    final basePayload = <String, dynamic>{
      'date_start': _formatToApiDate(startDate.value),
      'date_end': _formatToApiDate(endDate.value),
      'leave_type': _mappedLeaveType,
      'reason': reason,
      'class_id': selectedClassIds,
      if (selectedSectionId != null) 'section_id': <dynamic>[selectedSectionId],
    };

    try {
      await Get.find<ApiService>().post(
        EndPoints.parentLeaveRequest(studentId),
        basePayload,
        isShowLoading: false,
      );

      // Immediate local feedback so AllRequestedCard shows "pending" right away.
      final submitName = studentNameText.value.trim();
      final rawGrade = studentGradeText.value.trim();
      final normalizedGrade = rawGrade.toLowerCase();
      final submitGrade =
          rawGrade.isEmpty ||
                  normalizedGrade == 'n/a' ||
                  normalizedGrade == 'na' ||
                  normalizedGrade == 'null' ||
                  normalizedGrade == '-'
              ? ''
              : rawGrade;
      final pendingRequest = RequestLeaveModel(
        studentId: studentId,
        name: submitName.isEmpty ? 'Student' : submitName,
        grade: submitGrade,
        dateStart: startDate.value,
        dateEnd: endDate.value,
        leaveType: _mappedLeaveType,
        reason: reason,
        status: 'pending',
      );
      requests.insert(0, pendingRequest);
      await _appendCachedPending(studentId, pendingRequest);

      reasonController.clear();
      startDate.value = '';
      endDate.value = '';
      leaveType.value = '';
      return pendingRequest;
    } catch (e) {
      ExceptionHandler.handleException(e);
      return null;
    } finally {
      isloading.value = false;
    }
  }

  Future<void> fetchTracking() async {
    try {
      final Map<String, dynamic> param = {'invoice': searchCtl.text};
      final res = await Get.find<ApiService>().get(
        EndPoints.tracking,
        queryParameters: param,
        isShowLoading: true,
      );
      final data = getPropertyFromJson(res.data, 'data');
      trackings.value = List.from(
        (data as List).map((e) => TrackingModel.fromJson(e)).toList(),
      );

      isDone = true;
      DialogManager.hideLoading();
    } catch (e) {
      ExceptionHandler.handleException(e);
    }
  }

  Future<void> _ensureStudentLookup() async {
    if (_studentsById.isNotEmpty) {
      return;
    }
    if (_selectedStudentService.children.isNotEmpty) {
      _updateStudentLookupFromProfiles(
        _selectedStudentService.children.toList(growable: false),
      );
      if (_studentsById.isNotEmpty) {
        return;
      }
    }
    await fetchSelectedStudentInfo();
  }

  void _updateStudentLookup(List<Student> students) {
    _studentsById.clear();
    for (final student in students) {
      final id = (student.id?.toString() ?? '').trim();
      final admissionNo = (student.admissionNo ?? '').trim();
      if (id.isNotEmpty) {
        _studentsById[id] = student;
      }
      if (admissionNo.isNotEmpty) {
        _studentsById[admissionNo] = student;
      }
    }
  }

  void _updateStudentLookupFromProfiles(List<ChildProfile> students) {
    _studentsById.clear();
    for (final student in students) {
      final id = student.id.trim();
      if (id.isNotEmpty) {
        _studentsById[id] = Student(
          id: int.tryParse(id),
          admissionNo: id,
          name: student.name,
          nameKh: student.name,
          profile: student.avatar,
          className: student.className,
        );
      }
    }
  }

  RequestLeaveModel _withStudentInfo(RequestLeaveModel item) {
    final studentKey = (item.studentId ?? '').trim();
    final student = studentKey.isEmpty ? null : _studentsById[studentKey];
    if (student == null) {
      return item;
    }

    final name = (item.name ?? '').trim();
    final grade = (item.grade ?? '').trim();
    return RequestLeaveModel(
      studentId: item.studentId,
      name: _isPlaceholderName(name) ? _studentDisplayName(student) : name,
      grade: _isValidText(grade) ? grade : (student.className ?? '').trim(),
      dateStart: item.dateStart,
      dateEnd: item.dateEnd,
      leaveType: item.leaveType,
      reason: item.reason,
      status: item.status,
    );
  }

  String _studentDisplayName(Student student) {
    final khmerName = (student.nameKh ?? '').trim();
    if (khmerName.isNotEmpty) {
      return khmerName;
    }
    return (student.name ?? '').trim();
  }

  bool _isValidText(String value) {
    final text = value.trim().toLowerCase();
    return text.isNotEmpty &&
        text != 'n/a' &&
        text != 'na' &&
        text != 'null' &&
        text != '-';
  }

  bool _isPlaceholderName(String value) {
    final text = value.trim().toLowerCase();
    return text.isEmpty ||
        text == 'student' ||
        text == 'n/a' ||
        text == 'na' ||
        text == 'null' ||
        text == '-';
  }

  List<dynamic> _selectedClassIds() {
    return selectedClasses
        .map((name) => _classIdsByName[name.trim()])
        .where((id) => id != null && id.toString().trim().isNotEmpty)
        .toList();
  }

  dynamic _selectedSectionId() {
    final id = _sectionIdsByName[selectedSection.value.trim()];
    if (id == null || id.toString().trim().isEmpty) {
      return null;
    }
    return id;
  }

  /// Parses `/parent/student-class-section/{studentId}` — confirmed via
  /// API docs to return one row per class, each with its own nested
  /// `class: {id, name}` and `section: {id, name}` objects. This is the
  /// authoritative source for the class↔section relationship: neither
  /// `/parent/student-class/{id}` nor `/parent/student-section/{id}`
  /// cross-reference each other at all (the latter is a flat, generic
  /// "list all sections" reference with no class awareness whatsoever).
  List<_RequestLeaveOption> _extractStudentClassSectionOptions(dynamic raw) {
    final rows = _extractOptionRows(raw);
    final options = <_RequestLeaveOption>[];

    for (final row in rows) {
      final classRaw = row['class'];
      final sectionRaw = row['section'];

      String className;
      dynamic classId;
      if (classRaw is Map) {
        final classMap = Map<String, dynamic>.from(classRaw);
        className =
            _readFirstValue(classMap, const <String>[
              'name',
              'class_name',
              'className',
              'title',
              'label',
            ]).toString().trim();
        classId = _readFirstValue(classMap, const <String>[
          'id',
          'class_id',
          'classId',
        ]);
      } else {
        // Fallback: the older flat-row shape, in case a row doesn't nest
        // a class object.
        className =
            _readFirstValue(row, const <String>[
              'class',
              'class_name',
              'className',
              'student_class',
              'studentClass',
              'grade',
              'name',
              'title',
              'label',
            ]).toString().trim();
        classId = _readFirstValue(row, const <String>[
          'class_id',
          'classId',
          'id',
        ]);
      }
      if (className.isEmpty || className.toLowerCase() == 'null') {
        continue;
      }

      String? sectionName;
      dynamic sectionId;
      if (sectionRaw is Map) {
        final sectionMap = Map<String, dynamic>.from(sectionRaw);
        sectionName =
            _readFirstValue(sectionMap, const <String>[
              'name',
              'section_name',
              'sectionName',
              'title',
              'label',
            ]).toString().trim();
        sectionId = _readFirstValue(sectionMap, const <String>[
          'id',
          'section_id',
          'sectionId',
        ]);
      }
      if (sectionName != null &&
          (sectionName.isEmpty || sectionName.toLowerCase() == 'null')) {
        sectionName = null;
      }

      options.add(
        _RequestLeaveOption(
          name: className,
          id:
              classId != null && classId.toString().trim().isNotEmpty
                  ? classId
                  : null,
          sectionName: sectionName,
          sectionId:
              sectionId != null && sectionId.toString().trim().isNotEmpty
                  ? sectionId
                  : null,
        ),
      );
    }

    if (options.isNotEmpty) {
      return _dedupeOptions(options);
    }
    return _extractStudentClasses(
      raw,
    ).map((name) => _RequestLeaveOption(name: name)).toList();
  }

  List<_RequestLeaveOption> _extractStudentSectionOptions(dynamic raw) {
    final options =
        _extractOptionRows(raw)
            .map(
              (row) => _readOption(
                row,
                nameKeys: const <String>[
                  'section',
                  'section_name',
                  'sectionName',
                  'student_section',
                  'studentSection',
                  'shift',
                  'shift_name',
                  'shiftName',
                  'name',
                  'title',
                  'value',
                  'label',
                ],
              ),
            )
            .where((item) => item.name.isNotEmpty)
            .toList();
    if (options.isNotEmpty) {
      return _dedupeOptions(options);
    }

    return _extractStudentSections(
      raw,
    ).map((name) => _RequestLeaveOption(name: name)).toList();
  }

  List<_RequestLeaveOption> _dedupeOptions(List<_RequestLeaveOption> options) {
    final seen = <String>{};
    return options.where((item) => seen.add(item.name.toLowerCase())).toList();
  }

  _RequestLeaveOption _readOption(
    Map<String, dynamic> row, {
    required List<String> nameKeys,
  }) {
    final id = _readFirstValue(row, const <String>[
      'id',
      'class_id',
      'classId',
      'section_id',
      'sectionId',
    ]);
    final name = _readFirstValue(row, nameKeys).toString().trim();
    final hasId = id != null && id.toString().trim().isNotEmpty;
    return _RequestLeaveOption(
      id: hasId ? id : null,
      name: name.toLowerCase() == 'null' ? '' : name,
    );
  }

  dynamic _readFirstValue(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value == null || value.toString().trim().isEmpty) {
        continue;
      }
      return value;
    }
    return null;
  }

  List<Map<String, dynamic>> _extractOptionRows(dynamic raw, [int depth = 0]) {
    if (raw == null || depth > 4) {
      return const <Map<String, dynamic>>[];
    }
    if (raw is List) {
      return raw.expand((item) => _extractOptionRows(item, depth + 1)).toList();
    }
    if (raw is! Map) {
      return const <Map<String, dynamic>>[];
    }

    final map = Map<String, dynamic>.from(raw);
    if (map.containsKey('data')) {
      final rows = _extractOptionRows(map['data'], depth + 1);
      if (rows.isNotEmpty) {
        return rows;
      }
    }

    for (final key in const <String>[
      'classes',
      'sections',
      'student_classes',
      'student_sections',
      'studentClasses',
      'studentSections',
      'items',
      'rows',
      'list',
    ]) {
      final rows = _extractOptionRows(map[key], depth + 1);
      if (rows.isNotEmpty) {
        return rows;
      }
    }

    return <Map<String, dynamic>>[map];
  }

  List<String> _extractStudentClasses(dynamic raw) {
    final classes = _readStudentClassValues(raw);
    final seen = <String>{};
    return classes.map((item) => item.trim()).where((item) {
      if (item.isEmpty || item.toLowerCase() == 'null') {
        return false;
      }
      return seen.add(item.toLowerCase());
    }).toList();
  }

  List<String> _readStudentClassValues(dynamic raw, [int depth = 0]) {
    if (raw == null || depth > 4) {
      return const <String>[];
    }
    if (raw is String || raw is num || raw is bool) {
      final value = raw.toString().trim();
      return value.toLowerCase() == 'null' ? const <String>[] : <String>[value];
    }
    if (raw is List) {
      final values = <String>[];
      for (final item in raw) {
        values.addAll(_readStudentClassValues(item, depth + 1));
      }
      return values;
    }
    if (raw is! Map) {
      return const <String>[];
    }

    final map = Map<String, dynamic>.from(raw);
    if (map.containsKey('data')) {
      final values = _readStudentClassValues(map['data'], depth + 1);
      if (values.isNotEmpty) {
        return values;
      }
    }

    for (final key in const <String>[
      'classes',
      'student_classes',
      'studentClasses',
      'items',
      'rows',
      'list',
    ]) {
      final values = _readStudentClassValues(map[key], depth + 1);
      if (values.isNotEmpty) {
        return values;
      }
    }

    for (final key in const <String>[
      'class',
      'class_name',
      'className',
      'student_class',
      'studentClass',
      'grade',
      'name',
      'title',
      'label',
    ]) {
      final values = _readStudentClassValues(map[key], depth + 1);
      if (values.isNotEmpty) {
        return values;
      }
    }

    return const <String>[];
  }

  List<String> _extractStudentSections(dynamic raw) {
    final sections = _readStudentSectionValues(raw);
    final seen = <String>{};
    return sections.map((section) => section.trim()).where((section) {
      final value = section.trim();
      if (value.isEmpty || value.toLowerCase() == 'null') {
        return false;
      }
      return seen.add(value.toLowerCase());
    }).toList();
  }

  List<String> _readStudentSectionValues(dynamic raw, [int depth = 0]) {
    if (raw == null || depth > 4) {
      return const <String>[];
    }
    if (raw is String || raw is num || raw is bool) {
      final value = raw.toString().trim();
      return value.toLowerCase() == 'null' ? const <String>[] : <String>[value];
    }
    if (raw is List) {
      final values = <String>[];
      for (final item in raw) {
        values.addAll(_readStudentSectionValues(item, depth + 1));
      }
      return values;
    }
    if (raw is! Map) {
      return const <String>[];
    }

    final map = Map<String, dynamic>.from(raw);
    if (map.containsKey('data')) {
      final values = _readStudentSectionValues(map['data'], depth + 1);
      if (values.isNotEmpty) {
        return values;
      }
    }

    for (final key in const <String>[
      'sections',
      'student_sections',
      'studentSections',
      'items',
      'rows',
      'list',
    ]) {
      final values = _readStudentSectionValues(map[key], depth + 1);
      if (values.isNotEmpty) {
        return values;
      }
    }

    for (final key in const <String>[
      'section',
      'section_name',
      'sectionName',
      'student_section',
      'studentSection',
      'shift',
      'shift_name',
      'shiftName',
      'name',
      'title',
      'value',
      'label',
    ]) {
      final values = _readStudentSectionValues(map[key], depth + 1);
      if (values.isNotEmpty) {
        return values;
      }
    }

    return const <String>[];
  }

  Future<String> _selectedStudentId() async {
    final selectedId = _selectedStudentService.current?.id.trim() ?? '';
    if (selectedId.isNotEmpty) {
      return selectedId;
    }
    final selected =
        (await SharedPreferencesManager.get('selected_child_id') ?? '')
            .toString()
            .trim();
    if (selected.isNotEmpty) {
      return selected;
    }
    return (await SharedPreferencesManager.get(_lastLeaveStudentKey) ?? '')
        .toString()
        .trim();
  }

  List<Map<String, dynamic>> _extractRows(dynamic raw) {
    if (raw is! Map) {
      return const <Map<String, dynamic>>[];
    }

    final map = Map<String, dynamic>.from(raw);
    final candidates = <dynamic>[
      map['data'],
      map['leave_requests'],
      map['requests'],
      map['rows'],
      map['data'] is Map ? map['data']['data'] : null,
      map['data'] is Map ? map['data']['leave_requests'] : null,
      map['data'] is Map ? map['data']['requests'] : null,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<dynamic>()
            .map((e) {
              if (e is Map<String, dynamic>) return e;
              if (e is Map) return Map<String, dynamic>.from(e);
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }

  String _formatToApiDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final date = _parseDate(dateStr);
    if (date == null) return '';
    // Backend expects ISO-8601 UTC format, e.g. "2019-08-24T14:15:22Z".
    return "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date)}Z";
  }

  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }

  List<RequestLeaveModel> _mergeRequests(
    List<RequestLeaveModel> backend,
    List<RequestLeaveModel> cachedPending,
  ) {
    final merged = <RequestLeaveModel>[...backend];
    for (final pending in cachedPending) {
      if (!merged.any((e) => _sameRequestKey(e, pending))) {
        merged.insert(0, pending);
      }
    }
    return merged;
  }

  bool _sameRequestKey(RequestLeaveModel a, RequestLeaveModel b) {
    final aStudent = (a.studentId ?? '').trim();
    final bStudent = (b.studentId ?? '').trim();
    if (aStudent.isNotEmpty && bStudent.isNotEmpty && aStudent != bStudent) {
      return false;
    }

    final aStart = _normalizeDateKey(a.dateStart);
    final bStart = _normalizeDateKey(b.dateStart);
    final aEnd = _normalizeDateKey(a.dateEnd);
    final bEnd = _normalizeDateKey(b.dateEnd);
    final aType = (a.leaveType ?? '').trim().toLowerCase();
    final bType = (b.leaveType ?? '').trim().toLowerCase();
    final sameDateWindow = aStart == bStart && aEnd == bEnd;

    // Keep matching lenient so backend-approved records replace local pending
    // even when reason text or formatting differs.
    if (!sameDateWindow) {
      return false;
    }
    if (aType.isEmpty || bType.isEmpty) {
      return true;
    }
    return aType == bType;
  }

  String _normalizeDateKey(String? input) {
    final raw = (input ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }

    final slash = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(raw);
    if (slash != null) {
      return '${slash.group(3)}-${slash.group(2)}-${slash.group(1)}';
    }

    // Prefer extracting date part directly to avoid timezone/day shifts.
    final dateOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (dateOnly != null) {
      return '${dateOnly.group(1)}-${dateOnly.group(2)}-${dateOnly.group(3)}';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    }

    return raw;
  }

  Future<void> _appendCachedPending(
    String studentId,
    RequestLeaveModel request,
  ) async {
    final current = await _loadCachedPending(studentId);
    if (!current.any((e) => _sameRequestKey(e, request))) {
      current.insert(0, request);
      await _saveCachedPending(studentId, current);
    }
  }

  Future<List<RequestLeaveModel>> _loadCachedPending(String studentId) async {
    final raw = await SharedPreferencesManager.get(_cacheKey(studentId));
    if (raw is! String || raw.trim().isEmpty) {
      return <RequestLeaveModel>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <RequestLeaveModel>[];
      }
      return decoded
          .whereType<dynamic>()
          .map((e) {
            if (e is Map<String, dynamic>) {
              return RequestLeaveModel.fromJson(e);
            }
            if (e is Map) {
              return RequestLeaveModel.fromJson(Map<String, dynamic>.from(e));
            }
            return null;
          })
          .whereType<RequestLeaveModel>()
          .map(_withStudentInfo)
          .toList();
    } catch (_) {
      return <RequestLeaveModel>[];
    }
  }

  Future<void> _saveCachedPending(
    String studentId,
    List<RequestLeaveModel> list,
  ) async {
    final encoded = jsonEncode(
      list
          .map(
            (e) => <String, dynamic>{
              'name': e.name ?? '',
              'student_id': e.studentId ?? '',
              'grade': e.grade ?? '',
              'date_start': e.dateStart ?? '',
              'date_end': e.dateEnd ?? '',
              'leave_type': e.leaveType ?? '',
              'reason': e.reason ?? '',
              'status': e.status ?? 'pending',
            },
          )
          .toList(),
    );
    await SharedPreferencesManager.setValue(_cacheKey(studentId), encoded);
  }

  String _cacheKey(String studentId) => '$_pendingCachePrefix$studentId';

  List<String> _requestCacheScopes(
    String selectedRaw,
    String selectedResolved,
  ) {
    final scopes = <String>{};
    if (selectedRaw.trim().isNotEmpty) {
      scopes.add(selectedRaw.trim());
    }
    if (selectedResolved.trim().isNotEmpty) {
      scopes.add(selectedResolved.trim());
    }
    if (scopes.isEmpty) {
      scopes.add('all');
    }
    return scopes.toList();
  }

  Future<List<RequestLeaveModel>> _loadCachedPendingForScopes(
    List<String> scopes,
  ) async {
    final result = <RequestLeaveModel>[];
    for (final scope in scopes) {
      final rows = await _loadCachedPending(scope);
      for (final row in rows) {
        if (!result.any((e) => _sameRequestKey(e, row))) {
          result.add(row);
        }
      }
    }
    return result;
  }

  Future<void> _saveCachedPendingForScopes(
    List<RequestLeaveModel> pending,
  ) async {
    final grouped = <String, List<RequestLeaveModel>>{};
    for (final item in pending) {
      final scope = (item.studentId ?? '').trim();
      final key = scope.isEmpty ? 'all' : scope;
      grouped.putIfAbsent(key, () => <RequestLeaveModel>[]).add(item);
    }

    final scopes = <String>{..._studentsById.keys, ...grouped.keys};
    if (scopes.isEmpty) {
      scopes.add('all');
    }
    for (final scope in scopes) {
      await _saveCachedPending(scope, grouped[scope] ?? <RequestLeaveModel>[]);
    }
  }

  List<Map<String, dynamic>> _filterRowsBySelectedStudent({
    required List<Map<String, dynamic>> rows,
    required String selectedRaw,
    required String selectedResolved,
  }) {
    final raw = selectedRaw.trim();
    final resolved = selectedResolved.trim();
    if (raw.isEmpty && resolved.isEmpty) {
      return rows;
    }

    bool matches(Map<String, dynamic> row) {
      final candidates = <String>[
        (row['student_id'] ?? '').toString().trim(),
        (row['studentId'] ?? '').toString().trim(),
        (row['student'] is Map ? row['student']['id'] : '').toString().trim(),
        (row['admission_no'] ?? '').toString().trim(),
        (row['student_code'] ?? '').toString().trim(),
      ]..removeWhere((e) => e.isEmpty || e.toLowerCase() == 'null');

      if (resolved.isNotEmpty && candidates.contains(resolved)) {
        return true;
      }
      if (raw.isNotEmpty && candidates.contains(raw)) {
        return true;
      }
      return false;
    }

    final filtered = rows.where(matches).toList();
    return filtered;
  }

  Future<String> _resolveStudentIdForRequest(String selected) async {
    final raw = selected.trim();
    if (raw.isEmpty) {
      return '';
    }
    if (RegExp(r'^\d+$').hasMatch(raw)) {
      return raw;
    }

    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.parentStudentInfo,
        isShowLoading: false,
      );
      if (res.data is! Map) {
        return '';
      }
      final model = ParentWithChild.fromJson(
        Map<String, dynamic>.from(res.data),
      );
      final students = model.data?.student ?? const <Student>[];
      for (final s in students) {
        final id = (s.id?.toString() ?? '').trim();
        final admission = (s.admissionNo ?? '').trim();
        if (id == raw || admission == raw) {
          return id;
        }
      }
    } catch (_) {
      return '';
    }
    return '';
  }
}

class _RequestLeaveOption {
  const _RequestLeaveOption({
    required this.name,
    this.id,
    this.sectionName,
    this.sectionId,
  });

  final String name;
  final dynamic id;

  /// Populated for class rows that bundle their own section directly (see
  /// RequestLeaveController._extractStudentClassSectionOptions) — the
  /// authoritative source, confirmed via API docs.
  final String? sectionName;
  final dynamic sectionId;
}
