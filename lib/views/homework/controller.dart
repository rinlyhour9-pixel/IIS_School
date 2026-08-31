import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:dio/dio.dart' as d;
import 'package:http_parser/http_parser.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';

class HomeworkController extends GetxController {
  final RxBool isAssignmentsLoading = false.obs;
  final RxBool isTeacherAssignmentsLoadingMore = false.obs;
  final RxBool isTeacherDashboardLoading = false.obs;
  final RxBool isTeacherClassOptionsLoading = false.obs;
  final RxBool isSubmittingAssignment = false.obs;
  final Rxn<TeacherDashboardModel> teacherDashboard =
      Rxn<TeacherDashboardModel>();
  bool shouldShowAssignmentsLoading = false;

  final RxList<HomeworkAssignment> assignedHomeworkItems =
      <HomeworkAssignment>[].obs;
  final RxList<HomeworkClassOption> teacherClassOptions =
      <HomeworkClassOption>[].obs;
  final RxInt selectedTeacherDashboardClassIndex = 0.obs;
  final RxBool hasHomeworkNotification = false.obs;
  final RxSet<String> submittedAssignmentIds = <String>{}.obs;
  final RxSet<String> submittingAssignmentIds = <String>{}.obs;
  final RxSet<String> teacherSubmittingStudentIds = <String>{}.obs;
  final RxString teacherHomeworkError = ''.obs;
  final RxInt teacherHomeworkCurrentPage = 1.obs;
  final RxInt teacherHomeworkLastPage = 1.obs;
  final RxInt teacherHomeworkPerPage = 10.obs;
  final RxInt teacherHomeworkTotal = 0.obs;

  /// Every class the selected student is enrolled in. A student can be in
  /// more than one; the homework endpoint is scoped to a single class, so
  /// switching between them re-fetches rather than filtering locally.
  final RxList<StudentClassOption> studentClassOptions =
      <StudentClassOption>[].obs;
  final RxnInt selectedStudentClassId = RxnInt();
  String _studentClassOptionsStudentId = '';

  bool get isParentRole => UserRepository.shared.isParent;
  bool get hasMoreTeacherHomeworkPages =>
      teacherHomeworkCurrentPage.value < teacherHomeworkLastPage.value;
  List<String> get teacherDashboardClassLabels =>
      teacherClassOptions.map((option) => option.name).toList(growable: false);
  int get totalAssignments => assignedHomeworkItems.length;
  int get submittedAssignments => submittedAssignmentIds.length;
  int get pendingAssignments => totalAssignments - submittedAssignments;
  double get homeworkProgress =>
      totalAssignments == 0 ? 0 : submittedAssignments / totalAssignments;
  List<HomeworkAssignment> get pendingHomeworkItems => assignedHomeworkItems
      .where((item) => !submittedAssignmentIds.contains(item.id))
      .toList(growable: false);
  List<HomeworkAssignment> get submittedHomeworkItems => assignedHomeworkItems
      .where((item) => submittedAssignmentIds.contains(item.id))
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    if (isParentRole) {
      loadStudentClassOptions();
      fetchStudentHomeworks();
    } else {
      fetchTeacherClassOptions();
      fetchTeacherDashboardStats();
      fetchTeacherHomeworks();
    }
  }

  /// Loads the classes the selected student belongs to, and picks the one to
  /// show. Defaults to whatever class was already being shown so the screen
  /// lands exactly as it did before; falls back to the first class.
  Future<void> loadStudentClassOptions() async {
    if (!isParentRole) return;

    final studentId = await _resolveSelectedStudentId();
    final options = await StudentClassOptionsResolver.fetch(studentId);
    _studentClassOptionsStudentId = studentId;
    studentClassOptions.assignAll(options);

    if (options.isEmpty) {
      selectedStudentClassId.value = null;
      return;
    }

    final current =
        selectedStudentClassId.value ?? await _resolveStudentClassId();
    final matched = options.any((option) => option.id == current);
    selectedStudentClassId.value = matched ? current : options.first.id;
  }

  Future<void> selectStudentClass(int classId) async {
    if (!isParentRole || selectedStudentClassId.value == classId) return;
    selectedStudentClassId.value = classId;
    await fetchStudentHomeworks(resetBeforeLoad: true);
  }

  // Parent/student homework flow.
  Future<void> fetchStudentHomeworks({bool resetBeforeLoad = false}) async {
    if (isAssignmentsLoading.value) return;

    if (resetBeforeLoad) {
      assignedHomeworkItems.clear();
    }

    final selectedStudentId = await _resolveSelectedStudentId();
    // A different child has different classes, so drop the previous pick
    // before reloading — otherwise a stale class id leaks across children.
    if (selectedStudentId != _studentClassOptionsStudentId) {
      selectedStudentClassId.value = null;
      studentClassOptions.clear();
      await loadStudentClassOptions();
    }

    final fallbackClassName = await _resolveStudentClassName();
    // An explicitly picked class wins: the student may be in more than one
    // and the resolvers below only ever return a single cached class.
    final classId =
        selectedStudentClassId.value ??
        await _resolveStudentClassId() ??
        await _resolveClassIdFromClassName(fallbackClassName);
    print(
      'Student homework debug -> studentId: $selectedStudentId, '
      'classId: $classId, fallbackClassName: $fallbackClassName',
    );
    if (classId == null) {
      print('Student homework debug -> classId is null, clearing items');
      assignedHomeworkItems.clear();
      return;
    }

    try {
      isAssignmentsLoading.value = true;
      final cachedSubmittedIds = await _loadSubmittedHomeworkIds(
        selectedStudentId,
      );
      final res = await Get.find<ApiService>().get(
        EndPoints.studentHomeworks(classId),
        isShowLoading: false,
      );

      print('Student homework debug -> raw response: ${res.data}');
      final rows = _extractHomeworkRows(res.data);
      final items = rows
          .whereType<Map>()
          .map(
            (row) => _assignmentFromApi(
              Map<String, dynamic>.from(row),
              fallbackClassName: fallbackClassName,
            ),
          )
          .toList(growable: false);
      for (final row in rows.whereType<Map>()) {
        final map = Map<String, dynamic>.from(row);
        final id = (map['id'] ?? map['homework_id'] ?? '').toString();
        print(
          'Student homework debug -> row $id attachmentUrls: ${_readAttachmentUrls(map)} rawImages: ${map['images']}',
        );
      }
      print(
        'Student homework debug -> row count: ${rows.length}, '
        'item ids: ${items.map((item) => item.id).toList()}',
      );
      print(
        'Student homework debug -> item classes: '
        '${items.map((item) => '${item.id}:${item.className}/${item.classId}').toList()}',
      );
      assignedHomeworkItems.assignAll(items);

      final refreshedSubmittedIds = <String>{
        ...cachedSubmittedIds,
        for (final row in rows.whereType<Map>())
          if (_isAssignmentSubmittedFromApi(Map<String, dynamic>.from(row)))
            ((row['id'] ?? row['homework_id'] ?? '').toString().trim()),
      }..removeWhere((id) => id.isEmpty);

      final validIds =
          items
              .map((item) => item.id.trim())
              .where((id) => id.isNotEmpty)
              .toSet();
      submittedAssignmentIds
        ..clear()
        ..addAll(refreshedSubmittedIds.where(validIds.contains));
      await _saveSubmittedHomeworkIds(
        selectedStudentId,
        submittedAssignmentIds,
      );
      await _refreshParentHomeworkNotification(selectedStudentId);
    } catch (e) {
      print('Student homework debug -> fetch error: $e');
      assignedHomeworkItems.clear();
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      isAssignmentsLoading.value = false;
    }
  }

  // Teacher dashboard summary flow.
  Future<void> fetchTeacherDashboardStats() async {
    if (isTeacherDashboardLoading.value) return;

    final teacherId = await _resolveTeacherId();
    if (teacherId.isEmpty) return;

    try {
      isTeacherDashboardLoading.value = true;
      final res = await Get.find<ApiService>().get(
        EndPoints.teacherDashboard(teacherId),
        isShowLoading: false,
      );
      final raw = res.data;
      if (raw is! Map) return;

      final root = Map<String, dynamic>.from(raw);
      final source =
          root['data'] is Map ? Map<String, dynamic>.from(root['data']) : root;
      teacherDashboard.value = TeacherDashboardModel.fromJson(source);
    } catch (e) {
      ExceptionHandler.handleException(e);
    } finally {
      isTeacherDashboardLoading.value = false;
    }
  }

  Future<String> _resolveTeacherId() async {
    final storedUserId =
        (await SharedPreferencesManager.get('user_id') ?? '').toString().trim();
    if (storedUserId.isNotEmpty && storedUserId != '0') {
      return storedUserId;
    }

    final storedStaffCode =
        (await SharedPreferencesManager.get('staff_code') ?? '')
            .toString()
            .trim();
    if (storedStaffCode.isNotEmpty && storedStaffCode != '0') {
      return storedStaffCode;
    }

    try {
      final id = UserRepository.shared.profile.id.toString().trim();
      if (id.isNotEmpty && id != '0') return id;
    } catch (_) {}

    return '';
  }

  // Shared homework model builder used by teacher create/update flows.
  HomeworkAssignment buildAssignment({
    String? id,
    int? classId,
    required String title,
    required String className,
    required String deadline,
    required String description,
    String attachmentUrl = '',
    List<String> attachmentUrls = const <String>[],
    int submitted = 0,
    int total = 0,
  }) {
    return HomeworkAssignment(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      classId: classId,
      title: title,
      className: className,
      deadline: deadline.trim().isEmpty ? 'No deadline' : deadline.trim(),
      submitted: submitted,
      total: total,
      description: description,
      attachmentUrls:
          attachmentUrls.isNotEmpty
              ? attachmentUrls
              : (attachmentUrl.trim().isEmpty
                  ? const <String>[]
                  : <String>[attachmentUrl.trim()]),
    );
  }

  void requestAssignmentsLoading() {
    shouldShowAssignmentsLoading = true;
  }

  void addAssignment(HomeworkAssignment item) {
    assignedHomeworkItems.insert(0, item);
  }

  // Teacher homework list flow.
  Future<void> fetchTeacherHomeworks({bool reset = true}) async {
    if (reset) {
      if (isAssignmentsLoading.value) return;
    } else {
      if (isAssignmentsLoading.value ||
          isTeacherAssignmentsLoadingMore.value ||
          !hasMoreTeacherHomeworkPages) {
        return;
      }
    }

    try {
      if (reset) {
        isAssignmentsLoading.value = true;
        teacherHomeworkCurrentPage.value = 1;
      } else {
        isTeacherAssignmentsLoadingMore.value = true;
      }
      teacherHomeworkError.value = '';

      final res = await _getTeacherHomeworksPage(
        teacherHomeworkCurrentPage.value,
      );
      print('Teacher homework list debug -> raw response: ${res.data}');
      final rows = _extractHomeworkRows(res.data);
      print('Teacher homework list debug -> row count: ${rows.length}');
      if (rows.isEmpty) {
        if (reset) {
          assignedHomeworkItems.clear();
        }
        return;
      }

      final pagination = _extractPaginationMap(res.data);
      teacherHomeworkCurrentPage.value =
          _readPaginationInt(pagination, 'current_page') ??
          teacherHomeworkCurrentPage.value;
      teacherHomeworkLastPage.value =
          _readPaginationInt(pagination, 'last_page') ??
          teacherHomeworkCurrentPage.value;
      teacherHomeworkPerPage.value =
          _readPaginationInt(pagination, 'per_page') ??
          teacherHomeworkPerPage.value;
      teacherHomeworkTotal.value =
          _readPaginationInt(pagination, 'total') ?? rows.length;

      final parsed = rows
          .whereType<Map>()
          .map((row) {
            final assignment = _assignmentFromApi(
              Map<String, dynamic>.from(row),
            );
            final existing = assignedHomeworkItems.firstWhereOrNull(
              (item) => item.id == assignment.id,
            );
            if (assignment.attachmentUrls.isNotEmpty || existing == null) {
              return assignment;
            }
            return assignment.copyWith(attachmentUrls: existing.attachmentUrls);
          })
          .toList(growable: false);
      print(
        'Teacher homework list debug -> parsed item ids: ${parsed.map((item) => item.id).toList()}',
      );

      if (reset) {
        assignedHomeworkItems.assignAll(parsed);
      } else {
        assignedHomeworkItems.addAll(
          parsed.where(
            (item) =>
                !assignedHomeworkItems.any(
                  (existing) => existing.id == item.id,
                ),
          ),
        );
      }
      _updateTeacherClassOptions();
      await _refreshTeacherHomeworkNotification();
    } catch (e) {
      if (reset) {
        assignedHomeworkItems.clear();
      }
      teacherHomeworkError.value = e.toString();
      print('Teacher homework list debug -> fetch error: $e');
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      if (reset) {
        isAssignmentsLoading.value = false;
      } else {
        isTeacherAssignmentsLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreTeacherHomeworks() async {
    if (!hasMoreTeacherHomeworkPages) return;
    teacherHomeworkCurrentPage.value += 1;
    await fetchTeacherHomeworks(reset: false);
  }

  Future<d.Response> _getTeacherHomeworksPage(int page) async {
    final api = Get.find<ApiService>();
    final teacherId = await _resolveTeacherId();
    final queryParameters = <String, dynamic>{
      if (teacherId.isNotEmpty)
        'teacher_id': int.tryParse(teacherId) ?? teacherId,
      if (page > 1) 'page': page,
    };

    if (page <= 1 && queryParameters.isEmpty) {
      print('Teacher homework list debug -> GET ${EndPoints.teacherHomeworks}');
      return api.get(EndPoints.teacherHomeworks, isShowLoading: false);
    }

    try {
      print(
        'Teacher homework list debug -> GET ${EndPoints.teacherHomeworks} params=$queryParameters',
      );
      return await api.get(
        EndPoints.teacherHomeworks,
        queryParameters: queryParameters,
        isShowLoading: false,
      );
    } on d.DioException catch (e) {
      print(
        'Teacher homework list debug -> status: ${e.response?.statusCode}, '
        'body: ${e.response?.data}',
      );
      if (page == 1 && e.response?.statusCode == 422) {
        return api.get(EndPoints.teacherHomeworks, isShowLoading: false);
      }
      rethrow;
    }
  }

  Future<void> fetchAllTeacherHomeworks() async {
    while (isAssignmentsLoading.value) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    await fetchTeacherHomeworks();
    while (hasMoreTeacherHomeworkPages) {
      await loadMoreTeacherHomeworks();
    }
  }

  Future<void> fetchTeacherClassOptions() async {
    if (isTeacherClassOptionsLoading.value) return;

    try {
      isTeacherClassOptionsLoading.value = true;
      final res = await Get.find<ApiService>().get(
        EndPoints.classes,
        isShowLoading: false,
      );
      final rows = _extractHomeworkRows(res.data);
      if (rows.isEmpty) {
        return;
      }

      final options = <HomeworkClassOption>[];
      final seen = <String>{};
      for (final row in rows) {
        if (row is! Map) continue;
        final option = _classOptionFromApiMap(Map<String, dynamic>.from(row));
        if (option == null) continue;

        final key = _classOptionKey(option.id, option.name);
        if (seen.add(key)) {
          options.add(option);
        }
      }

      if (options.isNotEmpty) {
        teacherClassOptions.assignAll(options);
      }
    } catch (_) {
      // Keep existing options intact if the dedicated class lookup fails.
    } finally {
      isTeacherClassOptionsLoading.value = false;
    }
  }

  // Teacher homework detail/submission review flow.
  Future<HomeworkAssignmentDetail> fetchTeacherHomeworkDetail(String id) async {
    final res = await Get.find<ApiService>().get(
      EndPoints.teacherHomeworkDetail(id),
      isShowLoading: false,
    );
    final data = getPropertyFromJson(res.data, 'data');
    if (data is! Map) {
      throw Exception('Invalid homework detail response');
    }

    final detailMap = Map<String, dynamic>.from(data);
    final studentsRaw = res.data is Map ? (res.data as Map)['students'] : null;
    final students =
        studentsRaw is List
            ? studentsRaw
                .whereType<Map>()
                .map(
                  (row) => HomeworkSubmissionStudent.fromJson(
                    Map<String, dynamic>.from(row),
                  ),
                )
                .toList(growable: false)
            : const <HomeworkSubmissionStudent>[];

    return HomeworkAssignmentDetail(
      assignment: _assignmentFromApi(detailMap),
      students: students,
    );
  }

  /// Builds the multipart part for a homework attachment.
  ///
  /// Always sets an explicit `filename` and `contentType`. Without them Dio
  /// falls back to `application/octet-stream`, which servers that validate
  /// on MIME type (`image`, `mimes:...`) will reject or mishandle. The
  /// picker allows gif and pdf too, so both are mapped here — previously
  /// only jpg/png/webp were, and everything else silently became
  /// octet-stream.
  Future<d.MultipartFile> _multipartForAttachment(String path) async {
    final extension = path.split('.').last.toLowerCase();
    final mediaType = switch (extension) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'gif' => MediaType('image', 'gif'),
      'heic' => MediaType('image', 'heic'),
      'pdf' => MediaType('application', 'pdf'),
      _ => MediaType('application', 'octet-stream'),
    };
    return d.MultipartFile.fromFile(
      path,
      filename: _safeAttachmentName(File(path).uri.pathSegments.last),
      contentType: mediaType,
    );
  }

  /// Strips characters that commonly break `Content-Disposition` parsing on
  /// the server (spaces, parentheses, unicode). Gallery files routinely
  /// arrive named like `images (7).jpeg`.
  String _safeAttachmentName(String rawName) {
    final cleaned = rawName.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return cleaned.isEmpty || cleaned == '.' ? 'attachment' : cleaned;
  }

  // Teacher create homework flow.
  Future<HomeworkAssignment> createAssignment({
    required String title,
    required int? classId,
    required String className,
    required String deadline,
    required String description,
    String attachmentPath = '',
  }) async {
    final trimmedTitle = title.trim();
    final trimmedClassName = className.trim();
    final trimmedDescription = description.trim();
    final trimmedDeadline = deadline.trim();
    final trimmedAttachmentPath = attachmentPath.trim();
    final teacherId = await _resolveTeacherId();
    if (teacherId.isEmpty) {
      throw Exception('Teacher ID not found');
    }

    final localItem = buildAssignment(
      title: trimmedTitle,
      classId: classId,
      className: trimmedClassName,
      deadline: trimmedDeadline,
      description: trimmedDescription,
      attachmentUrls:
          trimmedAttachmentPath.isEmpty
              ? const <String>[]
              : <String>[trimmedAttachmentPath],
    );

    final formMap = <String, dynamic>{
      'class_id': classId,
      'teacher_id': int.tryParse(teacherId) ?? teacherId,
      'title': trimmedTitle,
      'description': trimmedDescription,
      'due_date': _deadlineForApi(trimmedDeadline),
    };
    if (trimmedAttachmentPath.isNotEmpty) {
      formMap['file'] = await _multipartForAttachment(trimmedAttachmentPath);
    }
    final payload = d.FormData.fromMap(formMap);

    try {
      isSubmittingAssignment.value = true;
      print(
        'Teacher homework create debug -> teacherId: $teacherId, classId: $classId, '
        'title: $trimmedTitle, due_date: ${_deadlineForApi(trimmedDeadline)}, '
        'attachmentPath: $trimmedAttachmentPath',
      );
      final res = await Get.find<ApiService>().post(
        EndPoints.teacherHomeworks,
        payload,
        isShowLoading: false,
      );
      print('Teacher homework create debug -> raw response: ${res.data}');
      // The server can return HTTP 200 with `success: false` (e.g. a
      // rejected validation) and no `data`. Without this check that fell
      // through to the "no data" branch below, which silently returned the
      // locally-built placeholder as if it had been saved — the UI showed
      // a success toast and navigated away even though nothing was created.
      _ensureApiCallSucceeded(res.data);
      final data = getPropertyFromJson(res.data, 'data');
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final attachmentUrls = _readAttachmentUrls(map);
        print(
          'Teacher homework create debug -> parsed attachmentUrls: $attachmentUrls',
        );
        final createdItem = HomeworkAssignment(
          id: (map['id'] ?? map['homework_id'] ?? localItem.id).toString(),
          classId: _findClassId(map) ?? classId,
          title: _readText(map, const [
            'title',
            'homework_title',
          ], trimmedTitle),
          className: _readText(map, const [
            'class_name',
            'class',
            'grade',
            'grade_name',
          ], trimmedClassName),
          deadline: _displayDeadline(
            _readText(map, const ['deadline', 'due_date'], trimmedDeadline),
          ),
          submitted: _readInt(map, const ['submitted', 'submitted_count']),
          total: _readInt(map, const [
            'total',
            'total_students',
            'student_count',
          ]),
          description: _readText(map, const [
            'description',
            'remark',
            'instructions',
          ], trimmedDescription),
          attachmentUrls:
              attachmentUrls.isNotEmpty
                  ? attachmentUrls
                  : localItem.attachmentUrls,
        );
        assignedHomeworkItems.insert(0, createdItem);
        return createdItem;
      }

      assignedHomeworkItems.insert(0, localItem);
      return localItem;
    } finally {
      isSubmittingAssignment.value = false;
    }
  }

  // Teacher update homework flow.
  Future<HomeworkAssignment> updateAssignment({
    required String id,
    required int? classId,
    required String title,
    required String className,
    required String deadline,
    required String description,
    int submitted = 0,
    int total = 0,
    String attachmentPath = '',
  }) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw Exception('Homework ID is missing');
    }

    final trimmedTitle = title.trim();
    final trimmedClassName = className.trim();
    final trimmedDescription = description.trim();
    final trimmedDeadline = deadline.trim();
    final trimmedAttachmentPath = attachmentPath.trim();
    final teacherId = await _resolveTeacherId();
    if (teacherId.isEmpty) {
      throw Exception('Teacher ID not found');
    }

    final localItem = buildAssignment(
      id: trimmedId,
      classId: classId,
      title: trimmedTitle,
      className: trimmedClassName,
      deadline: trimmedDeadline,
      description: trimmedDescription,
      attachmentUrls:
          trimmedAttachmentPath.isEmpty
              ? const <String>[]
              : <String>[trimmedAttachmentPath],
      submitted: submitted,
      total: total,
    );

    final formMap = <String, dynamic>{
      'class_id': classId,
      'teacher_id': int.tryParse(teacherId) ?? teacherId,
      'title': trimmedTitle,
      'description': trimmedDescription,
      'due_date': _deadlineForApi(trimmedDeadline),
    };
    if (trimmedAttachmentPath.isNotEmpty) {
      formMap['file'] = await _multipartForAttachment(trimmedAttachmentPath);
    }
    final payload = d.FormData.fromMap(formMap);

    try {
      isSubmittingAssignment.value = true;
      print(
        'Teacher homework update debug -> id: $trimmedId, teacherId: $teacherId, classId: $classId, '
        'title: $trimmedTitle, due_date: ${_deadlineForApi(trimmedDeadline)}, '
        'attachmentPath: $trimmedAttachmentPath',
      );
      final res = await Get.find<ApiService>().post(
        EndPoints.teacherHomeworkDetail(trimmedId),
        payload,
        isShowLoading: false,
      );
      print('Teacher homework update debug -> raw response: ${res.data}');
      _ensureApiCallSucceeded(res.data);
      final data = getPropertyFromJson(res.data, 'data');
      HomeworkAssignment updatedItem = localItem;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final attachmentUrls = _readAttachmentUrls(map);
        print(
          'Teacher homework update debug -> parsed attachmentUrls: $attachmentUrls',
        );
        updatedItem = HomeworkAssignment(
          id: (map['id'] ?? map['homework_id'] ?? localItem.id).toString(),
          classId: _findClassId(map) ?? classId,
          title: _readText(map, const [
            'title',
            'homework_title',
          ], trimmedTitle),
          className: _readHomeworkClassName(map, trimmedClassName),
          deadline: _displayDeadline(
            _readText(map, const ['deadline', 'due_date'], trimmedDeadline),
          ),
          submitted: _readInt(map, const ['submitted', 'submitted_count']),
          total: _readInt(map, const [
            'total',
            'total_students',
            'student_count',
          ]),
          description: _readText(map, const [
            'description',
            'remark',
            'instructions',
          ], trimmedDescription),
          attachmentUrls:
              attachmentUrls.isNotEmpty
                  ? attachmentUrls
                  : localItem.attachmentUrls,
        );
      }

      final index = assignedHomeworkItems.indexWhere(
        (current) => current.id == trimmedId,
      );
      if (index != -1) {
        assignedHomeworkItems[index] = updatedItem;
      }
      _updateTeacherClassOptions();
      return updatedItem;
    } finally {
      isSubmittingAssignment.value = false;
    }
  }

  Future<void> deleteAssignment(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw Exception('Homework ID is missing');
    }

    await Get.find<ApiService>().post(
      EndPoints.teacherHomeworkDelete(trimmedId),
      <String, dynamic>{},
      isShowLoading: false,
    );

    assignedHomeworkItems.removeWhere((item) => item.id == trimmedId);
    _updateTeacherClassOptions();
  }

  void replaceAssignment(HomeworkAssignment item) {
    final index = assignedHomeworkItems.indexWhere(
      (current) => current.id == item.id,
    );
    if (index == -1) return;
    assignedHomeworkItems[index] = item;
  }

  bool isStudentSubmitted(String assignmentId) {
    return submittedAssignmentIds.contains(assignmentId);
  }

  bool isStudentSubmitting(String assignmentId) {
    return submittingAssignmentIds.contains(assignmentId);
  }

  void submitStudentHomework(String assignmentId) {
    submittedAssignmentIds.add(assignmentId);
  }

  // Parent/student submission flow.
  Future<void> submitStudentHomeworkAnswer({
    required String homeworkId,
    String answerText = '',
    String? attachmentPath,
  }) async {
    final studentId = await StudentIdResolver.resolve();
    if (studentId == null) {
      throw Exception('Student ID not found');
    }

    final trimmedHomeworkId = homeworkId.trim();
    if (trimmedHomeworkId.isEmpty) {
      throw Exception('Homework ID is missing');
    }

    try {
      submittingAssignmentIds.add(trimmedHomeworkId);
      final trimmedAnswer = answerText.trim();
      final trimmedAttachmentPath = attachmentPath?.trim() ?? '';
      final hasAttachment = trimmedAttachmentPath.isNotEmpty;
      final formMap = <String, dynamic>{
        'homework_id': trimmedHomeworkId,
        'student_id': studentId.toString(),
        'submitted_by': studentId.toString(),
      };

      // Send the answer text whenever it exists. Some backends validate the
      // text field even when an attachment is included.
      if (trimmedAnswer.isNotEmpty) {
        formMap['answer_text'] = trimmedAnswer;
      }
      print('Homework submit fields: $formMap');
      print(
        'Homework submit debug -> homework_id: $trimmedHomeworkId, '
        'student_id: $studentId, '
        'submitted_by: $studentId, '
        'has_file: $hasAttachment, '
        'answer_length: ${trimmedAnswer.length}, '
        'file_path: $trimmedAttachmentPath',
      );
      if (hasAttachment) {
        formMap['file'] = await _multipartForAttachment(trimmedAttachmentPath);
      }

      final payload = d.FormData.fromMap(formMap);
      final res = await Get.find<ApiService>().post(
        EndPoints.studentHomeworkSubmit,
        payload,
        cusHeaders: const <String, dynamic>{
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
        },
        isShowLoading: false,
      );
      _ensureApiCallSucceeded(res.data);
      submittedAssignmentIds.add(trimmedHomeworkId);
      await _saveSubmittedHomeworkIds(
        studentId.toString(),
        submittedAssignmentIds,
      );
      await fetchStudentHomeworks();
    } on d.DioException catch (e) {
      print('Homework submit DioException: ${e.message}');
      print('Homework submit status: ${e.response?.statusCode}');
      print('Homework submit response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Homework submit error: $e');
      rethrow;
    } finally {
      submittingAssignmentIds.remove(trimmedHomeworkId);
    }
  }

  Future<void> markHomeworkNotificationsSeen() async {
    if (isParentRole) {
      final studentId = await _resolveSelectedStudentId();
      await _saveSeenHomeworkIds(studentId, _currentHomeworkIds());
    } else {
      await _saveSeenTeacherSubmissionCounts(_currentTeacherSubmissionCounts());
    }
    hasHomeworkNotification.value = false;
  }

  bool isTeacherSubmittingForStudent(String studentId) {
    return teacherSubmittingStudentIds.contains(studentId.trim());
  }

  Future<void> submitHomeworkForStudent({
    required String homeworkId,
    required HomeworkSubmissionStudent student,
    String answerText = '',
  }) async {
    final trimmedHomeworkId = homeworkId.trim();
    final trimmedStudentId = student.id.trim();
    if (trimmedHomeworkId.isEmpty) {
      throw Exception('Homework ID is missing');
    }
    if (trimmedStudentId.isEmpty) {
      throw Exception('Student ID is missing');
    }

    final teacherId = await _resolveTeacherId();
    if (teacherId.isEmpty) {
      throw Exception('Teacher ID not found');
    }

    try {
      teacherSubmittingStudentIds.add(trimmedStudentId);
      // Sent as multipart/form-data with `student_id[]` repeated per
      // student, matching the convention every other write endpoint in
      // this API uses (see images[] / delete_images[] on class-activity,
      // and the student-side submit flow above).
      //
      // This previously went out as a JSON body with student_id nested as
      // an array, which made the server fail with a raw PHP
      // "Object of class stdClass could not be converted to string" —
      // it never handled a JSON body for this route at all.
      final form =
          d.FormData()
            ..fields.addAll(<MapEntry<String, String>>[
              MapEntry('homework_id', trimmedHomeworkId),
              MapEntry('submitted_by', teacherId),
              MapEntry('answer_text', answerText.trim()),
              MapEntry('student_id[]', trimmedStudentId),
            ]);
      print('Teacher submit homework debug -> fields: ${form.fields}');
      final res = await Get.find<ApiService>().post(
        EndPoints.teacherSubmitHomework,
        form,
        isShowLoading: false,
      );
      print('Teacher submit homework debug -> raw response: ${res.data}');
      _ensureApiCallSucceeded(res.data);
    } finally {
      teacherSubmittingStudentIds.remove(trimmedStudentId);
    }
  }

  // Shared deadline formatting helpers for homework forms and API payloads.
  String formatDeadline(DateTime picked) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${picked.day} ${months[picked.month - 1]} ${picked.year}';
  }

  String _deadlineForApi(String deadline) {
    if (deadline.trim().isEmpty || deadline == 'No deadline') {
      return '';
    }
    final parsed = _parseDisplayDeadline(deadline);
    if (parsed == null) {
      return deadline.trim();
    }
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  String _displayDeadline(String raw) {
    final parsed = _parseDisplayDeadline(raw);
    if (parsed == null) {
      final text = raw.trim();
      if (text.isEmpty ||
          text == '0000-00-00 00:00:00' ||
          text.toLowerCase() == 'null') {
        return 'No deadline';
      }
      return text;
    }
    return formatDeadline(parsed);
  }

  DateTime? _parseDisplayDeadline(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final iso = DateTime.tryParse(text);
    if (iso != null) return iso;

    final parts = text.split(RegExp(r'\s+'));
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final year = int.tryParse(parts[2]);
    const months = <String, int>{
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final month = months[parts[1].toLowerCase()];
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  String _readText(
    Map<String, dynamic> map,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final text = (map[key] ?? '').toString().trim();
      final lower = text.toLowerCase();
      if (text.isNotEmpty &&
          lower != 'null' &&
          lower != 'n/a' &&
          lower != 'false' &&
          lower != 'undefined') {
        return text;
      }
    }
    return fallback;
  }

  int _readInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse((value ?? '').toString().trim());
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  HomeworkAssignment _assignmentFromApi(
    Map<String, dynamic> map, {
    String fallbackClassName = 'N/A',
  }) {
    final submitted = _readInt(map, const ['submitted', 'submitted_count']);
    final total = _readInt(map, const [
      'total_students',
      'total',
      'student_count',
    ]);
    final pending = _readInt(map, const ['pending']);

    return HomeworkAssignment(
      id: (map['id'] ?? '').toString(),
      classId: _findClassId(map),
      title: _readText(map, const ['title', 'homework_title'], 'Untitled'),
      className: _readHomeworkClassName(map, fallbackClassName),
      deadline: _displayDeadline(
        _readText(map, const ['due_date', 'deadline'], ''),
      ),
      submitted: submitted,
      total: total == 0 && pending > 0 ? submitted + pending : total,
      description: _readText(map, const [
        'description',
        'remark',
        'instructions',
      ], ''),
      attachmentUrls: _readAttachmentUrls(map),
    );
  }

  List<String> _readAttachmentUrls(Map<String, dynamic> map) {
    final urls = <String>[];
    final seen = <String>{};

    void addUrl(String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      if (seen.add(trimmed)) {
        urls.add(trimmed);
      }
    }

    for (final key in const [
      'image',
      'image_url',
      'file',
      'file_url',
      'attachment',
      'attachment_url',
      'photo',
      'photo_url',
      'url',
      'path',
      'src',
      'full_url',
      'original_url',
      'download_url',
    ]) {
      addUrl(_readText(map, <String>[key], ''));
    }

    final nestedKeys = <String>['images', 'attachments', 'files', 'photos'];
    for (final key in nestedKeys) {
      final value = map[key];
      if (value is List) {
        for (final item in value) {
          if (item is String && item.trim().isNotEmpty) {
            addUrl(item);
          }
          if (item is Map) {
            urls.addAll(_readAttachmentUrls(Map<String, dynamic>.from(item)));
          }
        }
      } else if (value is Map) {
        urls.addAll(_readAttachmentUrls(Map<String, dynamic>.from(value)));
      }
    }

    return urls.toSet().toList(growable: false);
  }

  void _updateTeacherClassOptions() {
    final merged = <HomeworkClassOption>[];
    final seen = <String>{};

    for (final option in teacherClassOptions) {
      final key = _classOptionKey(option.id, option.name);
      if (seen.add(key)) {
        merged.add(option);
      }
    }

    for (final item in assignedHomeworkItems) {
      final name = item.className.trim();
      if (name.isEmpty) continue;

      final option = HomeworkClassOption(id: item.classId, name: name);
      final key = _classOptionKey(option.id, option.name);
      if (seen.add(key)) {
        merged.add(option);
      }
    }

    if (merged.isNotEmpty) {
      teacherClassOptions.assignAll(merged);
    }
  }

  List<dynamic> _extractHomeworkRows(dynamic raw) {
    if (raw is String) {
      try {
        return _extractHomeworkRows(jsonDecode(raw));
      } catch (_) {
        return const <dynamic>[];
      }
    }
    if (raw is List) {
      return raw;
    }
    if (raw is! Map) {
      return const <dynamic>[];
    }

    final data = raw['data'];
    if (data is List) {
      return data;
    }
    if (data is Map) {
      final nested = data['data'];
      if (nested is List) {
        return nested;
      }
    }

    return const <dynamic>[];
  }

  Map<String, dynamic> _extractPaginationMap(dynamic raw) {
    if (raw is String) {
      try {
        return _extractPaginationMap(jsonDecode(raw));
      } catch (_) {
        return const <String, dynamic>{};
      }
    }
    if (raw is! Map) {
      return const <String, dynamic>{};
    }

    final map = Map<String, dynamic>.from(raw);
    if (map['data'] is List) {
      return map;
    }

    final data = map['data'];
    if (data is Map) {
      final nested = Map<String, dynamic>.from(data);
      if (nested['data'] is List) {
        return nested;
      }
    }

    return const <String, dynamic>{};
  }

  int? _readPaginationInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString().trim());
  }

  Future<int?> _resolveStudentClassId() async {
    if (Get.isRegistered<SelectedStudentService>()) {
      final selectedClassId =
          Get.find<SelectedStudentService>().current?.classId.trim() ?? '';
      final parsed = int.tryParse(selectedClassId);
      if (parsed != null) {
        return parsed;
      }
    }

    final cachedKeys = <String>[
      'selected_child_class_id',
      'student_info_class_id',
    ];
    for (final key in cachedKeys) {
      final raw =
          (await SharedPreferencesManager.get(key) ?? '').toString().trim();
      final parsed = int.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }

    try {
      final selectedStudentId =
          (await SharedPreferencesManager.get('selected_child_id') ?? '')
              .toString()
              .trim();
      final res = await Get.find<ApiService>().get(
        EndPoints.parentProfile,
        queryParameters:
            selectedStudentId.isEmpty
                ? null
                : <String, dynamic>{'student_id': selectedStudentId},
        isShowLoading: false,
      );
      print('parentProfile raw for classId resolve: ${res.data}'); // ADD THIS

      final classId = _findClassId(res.data);
      if (classId != null) {
        await SharedPreferencesManager.setValue(
          'selected_child_class_id',
          classId.toString(),
        );
        await SharedPreferencesManager.setValue(
          'student_info_class_id',
          classId.toString(),
        );
        return classId;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<String> _resolveSelectedStudentId() async {
    final resolved = await StudentIdResolver.resolve();
    if (resolved != null) {
      return resolved.toString().trim();
    }
    return (await SharedPreferencesManager.get('selected_child_id') ?? '')
        .toString()
        .trim();
  }

  Future<String> _resolveStudentClassName() async {
    if (Get.isRegistered<SelectedStudentService>()) {
      final selectedClassName =
          Get.find<SelectedStudentService>().current?.className.trim() ?? '';
      if (selectedClassName.isNotEmpty &&
          selectedClassName.toLowerCase() != 'n/a' &&
          selectedClassName.toLowerCase() != 'null') {
        return selectedClassName;
      }
    }

    final cachedKeys = <String>[
      'selected_child_class_name',
      'student_info_class_name',
    ];
    for (final key in cachedKeys) {
      final raw =
          (await SharedPreferencesManager.get(key) ?? '').toString().trim();
      if (raw.isNotEmpty &&
          raw.toLowerCase() != 'n/a' &&
          raw.toLowerCase() != 'null') {
        return raw;
      }
    }

    return 'N/A';
  }

  void _ensureApiCallSucceeded(dynamic raw) {
    if (raw is String) {
      final text = raw.trim().toLowerCase();
      if (text.startsWith('<!doctype html') ||
          text.startsWith('<html') ||
          text.contains('<body')) {
        throw 'Homework submit did not reach the API. Please log in again and try once more.';
      }
      return;
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final success = map['success'];
      if (success == false || success == 0 || success == '0') {
        final message =
            (map['message'] ?? map['error'] ?? map['detail'] ?? '')
                .toString()
                .trim();
        throw message.isEmpty ? 'Homework submit failed.' : message;
      }
    }
  }

  Future<int?> _findClassIdForSelectedStudent(
    dynamic raw,
    String selectedStudentId,
  ) async {
    if (raw is! Map) {
      return null;
    }

    final root = Map<String, dynamic>.from(raw);
    final data = root['data'];
    if (data is! Map) {
      return _findClassId(raw);
    }

    final studentsRaw = data['student'] ?? data['students'] ?? data['children'];
    if (studentsRaw is List) {
      for (final entry in studentsRaw) {
        if (entry is! Map) continue;
        final student = Map<String, dynamic>.from(entry);
        final idText =
            (student['id'] ?? student['student_id'] ?? '').toString().trim();
        if (selectedStudentId.isEmpty || idText == selectedStudentId) {
          final classId = _findClassId(student);
          if (classId != null) {
            return classId;
          }

          final className =
              (student['class_name'] ??
                      student['class'] ??
                      student['grade'] ??
                      '')
                  .toString()
                  .trim();
          if (className.isNotEmpty) {
            final resolved = await _resolveClassIdFromClassName(className);
            if (resolved != null) {
              return resolved;
            }
          }
        }
      }
    }

    return _findClassId(raw);
  }

  String _findClassNameForSelectedStudent(
    dynamic raw,
    String selectedStudentId,
  ) {
    if (raw is! Map) {
      return '';
    }

    final root = Map<String, dynamic>.from(raw);
    final data = root['data'];
    if (data is! Map) {
      return _readHomeworkClassName(root, '');
    }

    final studentsRaw = data['student'] ?? data['students'] ?? data['children'];
    if (studentsRaw is List) {
      for (final entry in studentsRaw) {
        if (entry is! Map) continue;
        final student = Map<String, dynamic>.from(entry);
        final idText =
            (student['id'] ?? student['student_id'] ?? '').toString().trim();
        if (selectedStudentId.isEmpty || idText == selectedStudentId) {
          return _readHomeworkClassName(student, '');
        }
      }
    }

    return _readHomeworkClassName(root, '');
  }

  Future<int?> _resolveClassIdFromClassName(String className) async {
    final normalized = className.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final option in teacherClassOptions) {
      if (option.name.trim().toLowerCase() == normalized &&
          option.id != null &&
          option.id! > 0) {
        return option.id;
      }
    }

    try {
      await fetchTeacherClassOptions();
      for (final option in teacherClassOptions) {
        if (option.name.trim().toLowerCase() == normalized &&
            option.id != null &&
            option.id! > 0) {
          return option.id;
        }
      }
    } catch (_) {}

    return null;
  }

  int? _findClassId(dynamic raw) {
    if (raw is List) {
      for (final item in raw) {
        final classId = _findClassId(item);
        if (classId != null) {
          return classId;
        }
      }
      return null;
    }
    if (raw is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(raw);
    final direct = map['class_id'] ?? map['classId'];
    if (direct is int) {
      return direct;
    }
    if (direct is num) {
      return direct.toInt();
    }
    if (direct != null) {
      final parsed = int.tryParse(direct.toString().trim());
      if (parsed != null) {
        return parsed;
      }
    }

    final rawClass = map['class'];
    if (rawClass is Map) {
      final nested = Map<String, dynamic>.from(rawClass);
      final nestedId = nested['id'] ?? nested['class_id'] ?? nested['classId'];
      if (nestedId is int) return nestedId;
      if (nestedId is num) return nestedId.toInt();
      if (nestedId != null) {
        final parsed = int.tryParse(nestedId.toString().trim());
        if (parsed != null) return parsed;
      }
    }

    for (final value in map.values) {
      final classId = _findClassId(value);
      if (classId != null) {
        return classId;
      }
    }
    return null;
  }

  String _readHomeworkClassName(Map<String, dynamic> map, String fallback) {
    final direct = _readText(map, const [
      'class_name',
      'class',
      'grade',
      'grade_name',
    ], '');
    final directLower = direct.toLowerCase();
    if (direct.isNotEmpty &&
        direct != '{}' &&
        !direct.startsWith('{') &&
        directLower != 'n/a' &&
        directLower != 'null' &&
        directLower != 'false' &&
        directLower != 'undefined') {
      return direct;
    }

    final rawClass = map['class'];
    if (rawClass is Map<String, dynamic>) {
      final nested = _readText(rawClass, const [
        'name',
        'class_name',
        'title',
        'label',
      ], '');
      if (nested.isNotEmpty) {
        return nested;
      }
    } else if (rawClass is Map) {
      final nested = _readText(Map<String, dynamic>.from(rawClass), const [
        'name',
        'class_name',
        'title',
        'label',
      ], '');
      if (nested.isNotEmpty) {
        return nested;
      }
    }

    final fallbackText = fallback.trim();
    final fallbackLower = fallbackText.toLowerCase();
    if (fallbackText.isNotEmpty &&
        fallbackLower != 'n/a' &&
        fallbackLower != 'null' &&
        fallbackLower != 'false' &&
        fallbackLower != 'undefined') {
      return fallbackText;
    }

    return 'N/A';
  }

  bool _isAssignmentSubmittedFromApi(Map<String, dynamic> map) {
    final directBoolKeys = <String>[
      'is_submitted',
      'submitted',
      'already_submitted',
      'has_submitted',
      'student_submitted',
    ];
    for (final key in directBoolKeys) {
      final value = map[key];
      if (value is bool) {
        return value;
      }
      final text = (value ?? '').toString().trim().toLowerCase();
      if (text == '1' || text == 'true' || text == 'yes') {
        return true;
      }
      if (text == '0' || text == 'false' || text == 'no') {
        return false;
      }
    }

    final statusKeys = <String>[
      'status',
      'submission_status',
      'submitted_status',
      'homework_status',
    ];
    for (final key in statusKeys) {
      final text = (map[key] ?? '').toString().trim().toLowerCase();
      if (text.contains('submit') || text == 'done' || text == 'completed') {
        return true;
      }
      if (text.contains('pending') || text.contains('not submit')) {
        return false;
      }
    }

    return false;
  }

  String _submittedHomeworkCacheKey(String studentId) {
    final safeStudentId =
        studentId.trim().isEmpty ? 'default' : studentId.trim();
    return 'submitted_homework_ids_$safeStudentId';
  }

  Future<Set<String>> _loadSubmittedHomeworkIds(String studentId) async {
    final raw =
        (await SharedPreferencesManager.get(
                  _submittedHomeworkCacheKey(studentId),
                ) ??
                '')
            .toString()
            .trim();
    if (raw.isEmpty) {
      return <String>{};
    }
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  Future<void> _saveSubmittedHomeworkIds(
    String studentId,
    Iterable<String> ids,
  ) async {
    final normalized =
        ids
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    await SharedPreferencesManager.setValue(
      _submittedHomeworkCacheKey(studentId),
      normalized.join(','),
    );
  }

  HomeworkClassOption? _classOptionFromApiMap(Map<String, dynamic> map) {
    final directClassId = _readInt(map, const ['id', 'class_id', 'classId']);
    final classId = directClassId > 0 ? directClassId : _findClassId(map);
    var className =
        _readText(map, const [
          'class_name',
          'name',
          'class',
          'grade',
          'grade_name',
        ], '').trim();
    if (className.startsWith('{') || className.toLowerCase() == 'null') {
      className = _readHomeworkClassName(map, '').trim();
    }
    if (classId == null ||
        classId <= 0 ||
        className.isEmpty ||
        className.toLowerCase() == 'n/a') {
      return null;
    }
    return HomeworkClassOption(id: classId, name: className);
  }

  String _classOptionKey(int? id, String name) {
    if (id != null && id > 0) {
      return 'id:$id';
    }
    return 'name:${name.trim().toLowerCase()}';
  }

  Future<void> _refreshParentHomeworkNotification(String studentId) async {
    final currentIds = _currentHomeworkIds();
    final seenIds = await _loadSeenHomeworkIds(studentId);
    hasHomeworkNotification.value = currentIds.any(
      (id) => !seenIds.contains(id),
    );
  }

  Future<void> _refreshTeacherHomeworkNotification() async {
    final currentCounts = _currentTeacherSubmissionCounts();
    final seenCounts = await _loadSeenTeacherSubmissionCounts();
    hasHomeworkNotification.value = currentCounts.entries.any((entry) {
      final seen = seenCounts[entry.key] ?? 0;
      return entry.value > seen;
    });
  }

  Iterable<String> _currentHomeworkIds() {
    return assignedHomeworkItems
        .map((item) => item.id.trim())
        .where((id) => id.isNotEmpty);
  }

  Map<String, int> _currentTeacherSubmissionCounts() {
    return <String, int>{
      for (final item in assignedHomeworkItems)
        if (item.id.trim().isNotEmpty) item.id.trim(): item.submitted,
    };
  }

  String _seenHomeworkIdsKey(String studentId) {
    final safeStudentId =
        studentId.trim().isEmpty ? 'default' : studentId.trim();
    return 'seen_homework_ids_$safeStudentId';
  }

  Future<Set<String>> _loadSeenHomeworkIds(String studentId) async {
    final raw =
        (await SharedPreferencesManager.get(_seenHomeworkIdsKey(studentId)) ??
                '')
            .toString()
            .trim();
    if (raw.isEmpty) {
      return <String>{};
    }
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  Future<void> _saveSeenHomeworkIds(
    String studentId,
    Iterable<String> ids,
  ) async {
    final normalized =
        ids
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    await SharedPreferencesManager.setValue(
      _seenHomeworkIdsKey(studentId),
      normalized.join(','),
    );
  }

  String _seenTeacherSubmissionCountsKey() {
    return 'seen_teacher_homework_submission_counts';
  }

  Future<Map<String, int>> _loadSeenTeacherSubmissionCounts() async {
    final raw =
        (await SharedPreferencesManager.get(
                  _seenTeacherSubmissionCountsKey(),
                ) ??
                '')
            .toString()
            .trim();
    if (raw.isEmpty) {
      return <String, int>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, int>{};
      }
      return <String, int>{
        for (final entry in decoded.entries)
          entry.key.toString(): int.tryParse(entry.value.toString()) ?? 0,
      };
    } catch (_) {
      return <String, int>{};
    }
  }

  Future<void> _saveSeenTeacherSubmissionCounts(Map<String, int> counts) async {
    await SharedPreferencesManager.setValue(
      _seenTeacherSubmissionCountsKey(),
      jsonEncode(counts),
    );
  }
}

class HomeworkAssignment {
  const HomeworkAssignment({
    required this.id,
    this.classId,
    required this.title,
    required this.className,
    required this.deadline,
    required this.submitted,
    required this.total,
    required this.description,
    this.attachmentUrls = const <String>[],
  });

  final String id;
  final int? classId;
  final String title;
  final String className;
  final String deadline;
  final int submitted;
  final int total;
  final String description;
  final List<String> attachmentUrls;
  String get attachmentUrl =>
      attachmentUrls.isEmpty ? '' : attachmentUrls.first;

  HomeworkAssignment copyWith({
    String? id,
    int? classId,
    String? title,
    String? className,
    String? deadline,
    int? submitted,
    int? total,
    String? description,
    List<String>? attachmentUrls,
  }) {
    return HomeworkAssignment(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      className: className ?? this.className,
      deadline: deadline ?? this.deadline,
      submitted: submitted ?? this.submitted,
      total: total ?? this.total,
      description: description ?? this.description,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    );
  }
}

class HomeworkClassOption {
  const HomeworkClassOption({required this.id, required this.name});

  final int? id;
  final String name;
}

class HomeworkAssignmentDetail {
  const HomeworkAssignmentDetail({
    required this.assignment,
    required this.students,
  });

  final HomeworkAssignment assignment;
  final List<HomeworkSubmissionStudent> students;
}

class HomeworkSubmissionStudent {
  const HomeworkSubmissionStudent({
    required this.id,
    required this.name,
    required this.status,
  });

  final String id;
  final String name;
  final String status;

  factory HomeworkSubmissionStudent.fromJson(Map<String, dynamic> json) {
    String firstText(List<String> keys, [String fallback = '']) {
      for (final key in keys) {
        final text = (json[key] ?? '').toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
      return fallback;
    }

    final status =
        firstText(const [
          'status',
          'submission_status',
          'submitted_status',
        ], 'pending').toLowerCase();
    final firstName = firstText(const ['firstname', 'first_name']);
    final lastName = firstText(const ['lastname', 'last_name']);
    final fullNameFromParts =
        [
          firstName,
          lastName,
        ].where((part) => part.trim().isNotEmpty).join(' ').trim();

    return HomeworkSubmissionStudent(
      id: firstText(const ['student_id', 'id', 'user_id', 'admission_id']),
      name:
          fullNameFromParts.isNotEmpty
              ? fullNameFromParts
              : firstText(const [
                'name',
                'student_name',
                'fullname',
                'full_name',
                'fullname_english',
                'fullname_khmer',
                'firstname',
                'first_name',
              ], 'Student'),
      status: status.contains('submit') ? 'submitted' : 'pending',
    );
  }
}
