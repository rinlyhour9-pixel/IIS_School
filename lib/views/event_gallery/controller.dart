import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:schoolapp/core/core.dart';

class ActivityController extends GetxController {
  final RxBool isSubmittingActivity = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxList<ClassActivityItem> activities = <ClassActivityItem>[].obs;
  final RxList<ActivityClassOption> teacherClassOptions =
      <ActivityClassOption>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt perPage = 10.obs;
  final RxInt total = 0.obs;
  String _lastStudentScopeKey = '';
  String _studentClassOptionsStudentId = '';

  /// Every class the selected student is enrolled in. A student can be in
  /// more than one; the activities endpoint is scoped to a single class, so
  /// switching between them re-fetches rather than filtering locally.
  final RxList<StudentClassOption> studentClassOptions =
      <StudentClassOption>[].obs;
  final RxnInt selectedStudentClassId = RxnInt();

  bool get isTeacherRole => !UserRepository.shared.isParent;
  bool get hasMorePages => currentPage.value < lastPage.value;

  @override
  void onInit() {
    super.onInit();
    fetchClassActivities();
    if (isTeacherRole) {
      fetchTeacherClassOptions();
    } else {
      loadStudentClassOptions();
    }
  }

  /// Loads the classes the selected student belongs to, and picks the one to
  /// show. Defaults to whatever class was already being shown so the screen
  /// lands exactly as it did before; falls back to the first class.
  Future<void> loadStudentClassOptions() async {
    if (isTeacherRole) return;

    final studentId = await _resolveSelectedStudentId();
    final options = await StudentClassOptionsResolver.fetch(studentId);
    _studentClassOptionsStudentId = studentId;
    studentClassOptions.assignAll(options);

    if (options.isEmpty) {
      selectedStudentClassId.value = null;
      return;
    }

    final current = selectedStudentClassId.value ?? await _resolveStudentClassId();
    final matched = options.any((option) => option.id == current);
    selectedStudentClassId.value = matched ? current : options.first.id;
  }

  Future<void> selectStudentClass(int classId) async {
    if (isTeacherRole || selectedStudentClassId.value == classId) return;
    selectedStudentClassId.value = classId;
    await fetchClassActivities();
  }

  Future<void> fetchClassActivities({bool reset = true}) async {
    if (reset) {
      if (isLoading.value) return;
    } else {
      if (isLoading.value || isLoadingMore.value || !hasMorePages) return;
    }

    try {
      if (reset) {
        isLoading.value = true;
        currentPage.value = 1;
      } else {
        isLoadingMore.value = true;
      }

      final studentScopeKey =
          isTeacherRole ? '' : await _resolveStudentScopeKey();
      final selectedStudentId =
          isTeacherRole ? '' : await _resolveSelectedStudentId();
      final studentClassName =
          isTeacherRole ? '' : await _resolveStudentClassName();
      // An explicitly picked class wins: the student may be in more than one
      // and the resolvers below only ever return a single cached class.
      final studentClassId =
          isTeacherRole
              ? null
              : selectedStudentClassId.value ??
                  await _resolveStudentClassId() ??
                  await _resolveClassIdFromClassName(studentClassName);
      if (!isTeacherRole && studentClassId == null) {
        if (reset) {
          activities.clear();
          currentPage.value = 1;
          lastPage.value = 1;
          total.value = 0;
        }
        return;
      }

      if (!isTeacherRole &&
          reset &&
          _lastStudentScopeKey.isNotEmpty &&
          _lastStudentScopeKey != studentScopeKey) {
        activities.clear();
        currentPage.value = 1;
        lastPage.value = 1;
      }

      final endpoint =
          isTeacherRole
              ? EndPoints.teacherClassActivity
              : EndPoints.classActivitiesByClass(studentClassId);
      final queryParameters =
          isTeacherRole
              ? <String, dynamic>{'page': currentPage.value}
              : <String, dynamic>{
                'page': currentPage.value,
                if (selectedStudentId.isNotEmpty)
                  'student_id': selectedStudentId,
              };

      final res = await Get.find<ApiService>().get(
        endpoint,
        queryParameters: queryParameters,
        isShowLoading: false,
      );

      if (res.data is! Map) {
        if (reset) {
          activities.clear();
        }
        return;
      }

      final root = Map<String, dynamic>.from(res.data as Map);
      final data = _extractActivitySection(root);
      final list = _extractActivityRows(root);
      if (list.isEmpty) {
        if (reset) {
          activities.clear();
        }
        return;
      }

      currentPage.value = (data?['current_page'] as num?)?.toInt() ?? 1;
      lastPage.value =
          (data?['last_page'] as num?)?.toInt() ?? currentPage.value;
      perPage.value = (data?['per_page'] as num?)?.toInt() ?? perPage.value;
      total.value = (data?['total'] as num?)?.toInt() ?? list.length;

      final List<ClassActivityItem> parsed =
          list
              .whereType<dynamic>()
              .map((e) {
                if (e is Map<String, dynamic>) {
                  return ClassActivityItem.fromJson(e);
                }
                if (e is Map) {
                  return ClassActivityItem.fromJson(
                    Map<String, dynamic>.from(e),
                  );
                }
                return const ClassActivityItem(
                  id: 0,
                  className: '',
                  title: '',
                  imageRefs: [],
                  description: '',
                  timeText: '',
                );
              })
              .where((e) => e.images.isNotEmpty || e.title.isNotEmpty)
              .toList();

      if (reset) {
        activities.assignAll(parsed);
      } else {
        activities.addAll(
          parsed.where(
            (item) => !activities.any((existing) => existing.id == item.id),
          ),
        );
      }
      if (!isTeacherRole) {
        _lastStudentScopeKey = studentScopeKey;
      }
      _updateTeacherClassOptionsFromActivities();
    } catch (e) {
      ExceptionHandler.handleException(e);
      if (reset) {
        activities.clear();
      }
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> refreshForSelectedStudent() async {
    if (isTeacherRole) return;

    // A different child has different classes, so drop the previous pick
    // before reloading — otherwise a stale class id leaks across children.
    final studentId = await _resolveSelectedStudentId();
    if (studentId != _studentClassOptionsStudentId) {
      selectedStudentClassId.value = null;
      studentClassOptions.clear();
      await loadStudentClassOptions();
    }

    final nextScopeKey = await _resolveStudentScopeKey();
    if (nextScopeKey == _lastStudentScopeKey) {
      return;
    }
    await fetchClassActivities();
  }

  Future<void> loadMoreActivities() async {
    if (!hasMorePages) return;
    currentPage.value += 1;
    await fetchClassActivities(reset: false);
  }

  Future<void> fetchTeacherClassOptions() async {
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.classes,
        isShowLoading: false,
      );

      final rows = _extractClassRows(res.data);
      if (rows is! List) return;

      final optionsByValue = <String, ActivityClassOption>{};
      for (final row in rows.whereType<Map>()) {
        final map = Map<String, dynamic>.from(row);
        final classId = _findClassId(map) ?? _readPositiveInt(map['id']);
        final className =
            _readClassName(map).trim().isNotEmpty
                ? _readClassName(map)
                : (map['class_name'] ?? map['name'] ?? '').toString().trim();
        final classLabel = className.trim();
        if (classId != null && classId > 0 && classLabel.isNotEmpty) {
          optionsByValue[classLabel.toLowerCase()] = ActivityClassOption(
            value: classId.toString(),
            name: classLabel,
          );
        }
      }

      if (optionsByValue.isNotEmpty) {
        teacherClassOptions.assignAll(
          optionsByValue.values.toList()..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          ),
        );
      }
    } catch (_) {
      // Leave existing options intact if the class lookup fails.
    }
  }

  Future<ClassActivityDetailItem?> fetchClassActivityDetail(int id) async {
    isDetailLoading.value = true;
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.classActivityDetails(id),
        isShowLoading: false,
      );

      if (res.data is! Map) return null;
      final map = Map<String, dynamic>.from(res.data as Map);
      final data = map['data'];
      if (data is! Map) return null;

      return ClassActivityDetailItem.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      ExceptionHandler.handleException(e);
      return null;
    } finally {
      isDetailLoading.value = false;
    }
  }

  /// Multipart field names for /teacher/class-activity (store) and
  /// /teacher/class-activity/update/{id}:
  /// - `images[]` — repeated per new file. The docs' curl sample shows a
  ///   bare `--form images=`, but live testing showed that name drops every
  ///   uploaded photo — the created activity comes back with no images at
  ///   all. That matches standard PHP/Laravel multipart parsing: repeated
  ///   fields sharing one name collapse to just the last part (or fail an
  ///   `array` validation rule) unless the name carries the `[]` suffix,
  ///   which is what actually builds an array server-side. The docs' own
  ///   example was simply wrong/incomplete for this array-of-files case.
  /// - `delete_images[]` — repeated per id to remove; anything already
  ///   attached and NOT listed here is kept. This is the inverse of what
  ///   this file originally assumed (a "keep list"); the real contract is a
  ///   "delete list". The docs typed this field as a plain `string`, which
  ///   read as "send one comma-joined value" — but that produced a raw PHP
  ///   `count(): Argument #1 ($value) must be of type Countable|array,
  ///   string given` from the server, proving it's actually consumed as an
  ///   array server-side and needs the same `[]` treatment as `images[]`.
  static const String _newImagesField = 'images[]';
  static const String _deleteImagesField = 'delete_images[]';

  Future<d.MultipartFile> _multipartForImage(String path) async {
    final extension = File(path).path.split('.').last.toLowerCase();
    final mediaType = switch (extension) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'heic' => MediaType('image', 'heic'),
      _ => MediaType('application', 'octet-stream'),
    };
    return d.MultipartFile.fromFile(
      path,
      filename: File(path).uri.pathSegments.last,
      contentType: mediaType,
    );
  }

  /// Attaches every path in [imagePaths] under `images[]`, and — when
  /// [coverImagePath] is given — attaches that same file a second time
  /// under the legacy singular `image` field, so the first photo also
  /// becomes the activity's cover for any consumer that still only reads
  /// `image`. The caller decides what counts as "first": on create it's
  /// simply the first pick; on update it's only set when there's no kept
  /// remote image ahead of it (a remote image can't be re-sent as binary
  /// without downloading it first).
  Future<void> _attachImages(
    d.FormData form,
    List<String> imagePaths, {
    String? coverImagePath,
  }) async {
    for (final rawPath in imagePaths) {
      final trimmedPath = rawPath.trim();
      if (trimmedPath.isEmpty) continue;
      form.files.add(
        MapEntry(_newImagesField, await _multipartForImage(trimmedPath)),
      );
    }

    final trimmedCover = coverImagePath?.trim() ?? '';
    if (trimmedCover.isNotEmpty) {
      form.files.add(MapEntry('image', await _multipartForImage(trimmedCover)));
    }
  }

  Future<ClassActivityItem?> createActivity({
    required String classId,
    required String title,
    required String description,
    List<String> imagePaths = const [],
    String? coverImagePath,
  }) async {
    if (isSubmittingActivity.value) {
      return null;
    }

    isSubmittingActivity.value = true;

    try {
      final trimmedClassId = classId.trim();
      if (trimmedClassId.isEmpty) {
        throw Exception('Class is required');
      }

      final trimmedTitle = title.trim();
      final trimmedDescription = description.trim();

      if (trimmedTitle.isEmpty) {
        throw Exception('Activity title is required');
      }
      // The API marks description as required — validate client-side so a
      // blank description surfaces a clear message instead of a raw 422.
      if (trimmedDescription.isEmpty) {
        throw Exception('Activity description is required');
      }

      final form =
          d.FormData()
            ..fields.addAll(<MapEntry<String, String>>[
              MapEntry('class_id', trimmedClassId),
              MapEntry('title', trimmedTitle),
              MapEntry('description', trimmedDescription),
              const MapEntry('status', 'active'),
            ]);

      await _attachImages(form, imagePaths, coverImagePath: coverImagePath);

      final res = await Get.find<ApiService>().post(
        EndPoints.teacherClassActivity,
        form,
        isShowLoading: false,
        sendTimeout: const Duration(seconds: 120),
      );

      final rawData = getPropertyFromJson(res.data, 'data');
      if (rawData is Map) {
        final createdMap = Map<String, dynamic>.from(rawData);
        final activityMap =
            createdMap['activity'] is Map
                ? Map<String, dynamic>.from(createdMap['activity'] as Map)
                : createdMap;
        final created = ClassActivityItem.fromJson(activityMap);
        unawaited(fetchClassActivities());
        return created;
      }

      unawaited(fetchClassActivities());
      return null;
    } finally {
      isSubmittingActivity.value = false;
    }
  }

  Future<ClassActivityItem?> updateActivity({
    required int id,
    required String classId,
    required String title,
    required String description,
    List<String> imagePaths = const [],
    List<int> deleteImageIds = const [],
    String? coverImagePath,
  }) async {
    if (isSubmittingActivity.value) {
      return null;
    }

    isSubmittingActivity.value = true;

    try {
      final trimmedClassId = classId.trim();
      if (trimmedClassId.isEmpty) {
        throw Exception('Class is required');
      }

      final trimmedTitle = title.trim();
      final trimmedDescription = description.trim();

      if (trimmedTitle.isEmpty) {
        throw Exception('Activity title is required');
      }
      // The API marks description as required — validate client-side so a
      // blank description surfaces a clear message instead of a raw 422.
      if (trimmedDescription.isEmpty) {
        throw Exception('Activity description is required');
      }

      final form =
          d.FormData()
            ..fields.addAll(<MapEntry<String, String>>[
              MapEntry('class_id', trimmedClassId),
              MapEntry('title', trimmedTitle),
              MapEntry('description', trimmedDescription),
              const MapEntry('status', 'active'),
              for (final deleteId in deleteImageIds)
                MapEntry(_deleteImagesField, deleteId.toString()),
            ]);

      await _attachImages(form, imagePaths, coverImagePath: coverImagePath);

      final res = await Get.find<ApiService>().post(
        EndPoints.teacherClassActivityUpdate(id),
        form,
        isShowLoading: false,
        sendTimeout: const Duration(seconds: 120),
      );

      final rawData = getPropertyFromJson(res.data, 'data');
      if (rawData is Map) {
        final updated = ClassActivityItem.fromJson(
          Map<String, dynamic>.from(rawData),
        );
        final index = activities.indexWhere((item) => item.id == id);
        if (index != -1) {
          activities[index] = updated;
        }
        unawaited(fetchClassActivities());
        return updated;
      }

      unawaited(fetchClassActivities());
      return null;
    } finally {
      isSubmittingActivity.value = false;
    }
  }

  Future<void> deleteActivity(int id) async {
    if (isSubmittingActivity.value) {
      return;
    }
    isSubmittingActivity.value = true;
    try {
      await Get.find<ApiService>().delete(
        EndPoints.teacherClassActivityDelete(id),
      );
      activities.removeWhere((item) => item.id == id);
      unawaited(fetchClassActivities());
    } finally {
      isSubmittingActivity.value = false;
    }
  }

  void _updateTeacherClassOptionsFromActivities() {
    final current = <String, ActivityClassOption>{
      for (final option in teacherClassOptions)
        option.name.toLowerCase(): option,
    };

    for (final activity in activities) {
      final classId = activity.classId;
      final className =
          activity.className.trim().isNotEmpty
              ? activity.className.trim()
              : _classLabelFromId(classId);
      if (classId != null && classId > 0 && className.isNotEmpty) {
        current[className.toLowerCase()] = ActivityClassOption(
          value: classId.toString(),
          name: className,
        );
      }
    }

    if (current.isEmpty) return;
    teacherClassOptions.assignAll(
      current.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    );
  }

  Map<String, dynamic>? _extractActivitySection(Map<String, dynamic> root) {
    final candidates = <dynamic>[root['class'], root['data']];
    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
      if (candidate is Map) {
        return Map<String, dynamic>.from(candidate);
      }
    }
    return null;
  }

  List<dynamic> _extractActivityRows(Map<String, dynamic> root) {
    final directCandidates = <dynamic>[root['class'], root['data']];
    for (final candidate in directCandidates) {
      if (candidate is List) {
        return candidate;
      }
    }

    final section = _extractActivitySection(root);
    if (section == null) {
      return const <dynamic>[];
    }

    final nestedCandidates = <dynamic>[
      section['data'],
      section['activities'],
      section['items'],
    ];
    for (final candidate in nestedCandidates) {
      if (candidate is List) {
        return candidate;
      }
    }

    return const <dynamic>[];
  }

  String _readClassName(Map<String, dynamic> map) {
    final raw =
        map['class_name'] ?? map['class'] ?? map['grade'] ?? map['name'] ?? '';
    if (raw is Map<String, dynamic>) {
      return (raw['name'] ?? raw['class_name'] ?? '').toString().trim();
    }
    if (raw is Map) {
      final nested = Map<String, dynamic>.from(raw);
      return (nested['name'] ?? nested['class_name'] ?? '').toString().trim();
    }
    return raw.toString().trim();
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
    return '';
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
      final selectedStudentId = await _resolveSelectedStudentId();
      final res = await Get.find<ApiService>().get(
        EndPoints.parentStudentInfo,
        queryParameters:
            selectedStudentId.isEmpty
                ? null
                : <String, dynamic>{'student_id': selectedStudentId},
        isShowLoading: false,
      );
      print('studentInfo raw for classId resolve: ${res.data}');

      final classId = await _findClassIdForSelectedStudent(
        res.data,
        selectedStudentId,
      );
      final className = _findClassNameForSelectedStudent(
        res.data,
        selectedStudentId,
      );
      if (classId != null) {
        await SharedPreferencesManager.setValue(
          'selected_child_class_id',
          classId.toString(),
        );
        await SharedPreferencesManager.setValue(
          'student_info_class_id',
          classId.toString(),
        );
      }
      if (className.isNotEmpty) {
        await SharedPreferencesManager.setValue(
          'selected_child_class_name',
          className,
        );
        await SharedPreferencesManager.setValue(
          'student_info_class_name',
          className,
        );
      }
      return classId;
    } catch (_) {
      return null;
    }
  }

  Future<String> _resolveStudentScopeKey() async {
    final selectedChildId =
        (await SharedPreferencesManager.get('selected_child_id') ?? '')
            .toString()
            .trim();
    final selectedClassId =
        (await SharedPreferencesManager.get('selected_child_class_id') ?? '')
            .toString()
            .trim();
    final selectedClassName =
        (await SharedPreferencesManager.get('selected_child_class_name') ?? '')
            .toString()
            .trim()
            .toLowerCase();
    // The picked class is part of the scope: without it, switching class
    // leaves the key unchanged and refreshForSelectedStudent() would skip
    // the refetch.
    return '$selectedChildId|$selectedClassId|$selectedClassName'
        '|${selectedStudentClassId.value ?? ''}';
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
      return _findClassId(root);
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

          final className = _readClassName(student);
          if (className.isNotEmpty) {
            final resolved = await _resolveClassIdFromClassName(className);
            if (resolved != null) {
              return resolved;
            }
          }
        }
      }
    }

    return _findClassId(root);
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
      return _readClassName(root);
    }

    final studentsRaw = data['student'] ?? data['students'] ?? data['children'];
    if (studentsRaw is List) {
      for (final entry in studentsRaw) {
        if (entry is! Map) continue;
        final student = Map<String, dynamic>.from(entry);
        final idText =
            (student['id'] ?? student['student_id'] ?? '').toString().trim();
        if (selectedStudentId.isEmpty || idText == selectedStudentId) {
          return _readClassName(student);
        }
      }
    }

    return _readClassName(root);
  }

  Future<int?> _resolveClassIdFromClassName(String className) async {
    final normalized = className.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.classes,
        isShowLoading: false,
      );
      final rows = _extractClassRows(res.data);
      if (rows is! List) {
        return _classIdFromClassName(className);
      }
      for (final row in rows) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);
        final rowClassName = _readClassName(map).toLowerCase();
        final rowClassId = _findClassId(map);
        if (rowClassName == normalized &&
            rowClassId != null &&
            rowClassId > 0) {
          return rowClassId;
        }
      }
    } catch (_) {}

    return _classIdFromClassName(className);
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

    for (final value in map.values) {
      final classId = _findClassId(value);
      if (classId != null) {
        return classId;
      }
    }
    return null;
  }

  int? _classIdFromClassName(String className) {
    final trimmed = className.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    const classIds = <String, int>{
      'K1': 1,
      'K2': 2,
      'K3': 3,
      'Grade 3A': 1,
      'Grade 4A': 2,
      'Grade 5B': 3,
    };

    final direct = classIds[trimmed];
    if (direct != null) {
      return direct;
    }

    final kinder = RegExp(
      r'^K\s*(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (kinder != null) {
      return int.tryParse(kinder.group(1)!);
    }

    return null;
  }

  dynamic _extractClassRows(dynamic raw) {
    if (raw is List) {
      return raw;
    }
    if (raw is! Map) {
      return null;
    }

    final data = raw['data'];
    if (data is List) {
      return data;
    }
    if (data is Map) {
      return data['data'];
    }

    return null;
  }

  int? _readPositiveInt(dynamic raw) {
    if (raw is int) {
      return raw > 0 ? raw : null;
    }
    if (raw is num) {
      final value = raw.toInt();
      return value > 0 ? value : null;
    }
    final parsed = int.tryParse((raw ?? '').toString().trim());
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  String _classLabelFromId(int? classId) {
    switch (classId) {
      case 1:
        return 'K1';
      case 2:
        return 'K2';
      case 3:
        return 'K3';
      default:
        return classId == null ? '' : 'Class $classId';
    }
  }
}

/// One activity image as returned by the API. [id] is the server-side
/// image id, used to tell the backend which images to keep on update; it is
/// null when the API returns bare URL/path strings with no per-image id.
class ActivityImageRef {
  const ActivityImageRef({this.id, required this.url});

  final int? id;
  final String url;
}

class ClassActivityItem {
  const ClassActivityItem({
    required this.id,
    this.classId,
    required this.className,
    required this.title,
    required this.imageRefs,
    required this.description,
    required this.timeText,
  });

  final int id;
  final int? classId;
  final String className;
  final String title;
  final List<ActivityImageRef> imageRefs;
  final String description;
  final String timeText;

  List<String> get images =>
      imageRefs
          .map((ref) => ref.url)
          .where((url) => url.isNotEmpty)
          .toList(growable: false);

  /// Back-compat: the first image, or '' when there are none.
  String get image => images.isEmpty ? '' : images.first;

  factory ClassActivityItem.fromJson(Map<String, dynamic> json) {
    final classId = _readActivityClassId(json);
    final className = _readActivityClassName(json);
    return ClassActivityItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      classId: classId,
      className:
          className.isNotEmpty ? className : _fallbackClassLabelFromId(classId),
      title: (json['title'] ?? '').toString().trim(),
      imageRefs: _readActivityImages(json),
      description: (json['description'] ?? '').toString().trim(),
      timeText: _firstNonEmpty(<dynamic>[
        json['time'],
        json['time_text'],
        json['activity_time'],
        json['created_at'],
        json['createdAt'],
        json['create_date'],
        json['created_date'],
        json['updated_at'],
        json['updatedAt'],
        json['update_date'],
        json['date'],
        json['publish_date'],
      ]),
    );
  }

  /// Tolerant, multi-key image parser. Prefers a gallery list (`images`,
  /// `photos`, `gallery`, `attachments`, `activity_images`) over the
  /// singular cover-image keys — the two are NOT merged, because APIs that
  /// return both typically already include the cover as the gallery's first
  /// entry, and merging would duplicate it.
  static List<ActivityImageRef> _readActivityImages(
    Map<String, dynamic> json,
  ) {
    final seenUrls = <String>{};
    final refs = <ActivityImageRef>[];

    void addRef(String rawUrl, {int? id}) {
      final trimmed = rawUrl.trim();
      if (trimmed.isEmpty) return;
      final lower = trimmed.toLowerCase();
      if (lower == 'null' || lower == 'undefined') return;
      if (seenUrls.add(trimmed)) {
        refs.add(ActivityImageRef(id: id, url: trimmed));
      }
    }

    String urlFromMap(Map<String, dynamic> map) {
      for (final key in const [
        'image',
        'image_url',
        'url',
        'path',
        'photo',
        'full_url',
        'file',
      ]) {
        final value = (map[key] ?? '').toString().trim();
        if (value.isNotEmpty && value.toLowerCase() != 'null') {
          return value;
        }
      }
      return '';
    }

    int? idFromMap(Map<String, dynamic> map) {
      final raw = map['id'] ?? map['image_id'];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      return int.tryParse((raw ?? '').toString().trim());
    }

    void collectFromList(List<dynamic> list) {
      for (final item in list) {
        if (item is String) {
          addRef(item);
        } else if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          addRef(urlFromMap(map), id: idFromMap(map));
        }
      }
    }

    for (final key in const [
      'images',
      'photos',
      'gallery',
      'attachments',
      'activity_images',
    ]) {
      final value = json[key];
      if (value is List && value.isNotEmpty) {
        collectFromList(value);
      } else if (value is Map) {
        final nestedList = Map<String, dynamic>.from(value)['data'];
        if (nestedList is List) collectFromList(nestedList);
      }
    }

    if (refs.isEmpty) {
      for (final key in const [
        'image',
        'image_url',
        'photo',
        'photo_url',
        'url',
        'path',
        'src',
        'full_url',
      ]) {
        addRef((json[key] ?? '').toString().trim());
      }
    }

    return refs;
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return '';
  }

  static int? _readActivityClassId(Map<String, dynamic> json) {
    final direct = json['class_id'] ?? json['classId'];
    if (direct is int) return direct;
    if (direct is num) return direct.toInt();

    final directParsed = int.tryParse((direct ?? '').toString().trim());
    if (directParsed != null) {
      return directParsed;
    }

    final nestedClass = json['class'];
    if (nestedClass is Map<String, dynamic>) {
      final nested = nestedClass['id'] ?? nestedClass['class_id'];
      if (nested is int) return nested;
      if (nested is num) return nested.toInt();
      return int.tryParse((nested ?? '').toString().trim());
    }
    if (nestedClass is Map) {
      final nested = Map<String, dynamic>.from(nestedClass);
      final value = nested['id'] ?? nested['class_id'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse((value ?? '').toString().trim());
    }

    return null;
  }

  static String _readActivityClassName(Map<String, dynamic> json) {
    final raw = json['class_name'] ?? json['class'] ?? json['grade'] ?? '';
    if (raw is Map<String, dynamic>) {
      return (raw['name'] ?? raw['class_name'] ?? '').toString().trim();
    }
    if (raw is Map) {
      final nested = Map<String, dynamic>.from(raw);
      return (nested['name'] ?? nested['class_name'] ?? '').toString().trim();
    }
    return raw.toString().trim();
  }

  static String _fallbackClassLabelFromId(int? classId) {
    switch (classId) {
      case 1:
        return 'K1';
      case 2:
        return 'K2';
      case 3:
        return 'K3';
      default:
        return classId == null ? '' : 'Class $classId';
    }
  }
}

class ClassActivityDetailItem {
  const ClassActivityDetailItem({
    required this.id,
    required this.title,
    required this.imageRefs,
    required this.description,
  });

  final int id;
  final String title;
  final List<ActivityImageRef> imageRefs;
  final String description;

  List<String> get images =>
      imageRefs
          .map((ref) => ref.url)
          .where((url) => url.isNotEmpty)
          .toList(growable: false);

  /// Back-compat: the first image, or '' when there are none.
  String get image => images.isEmpty ? '' : images.first;

  factory ClassActivityDetailItem.fromJson(Map<String, dynamic> json) {
    return ClassActivityDetailItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString().trim(),
      imageRefs: ClassActivityItem._readActivityImages(json),
      description: (json['description'] ?? '').toString().trim(),
    );
  }
}

class ActivityClassOption {
  const ActivityClassOption({required this.value, required this.name});

  final String value;
  final String name;
}
