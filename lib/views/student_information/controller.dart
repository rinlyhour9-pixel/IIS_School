import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/student_profile_history/model.dart';
import 'package:schoolapp/models/parent/parent.dart' as parent_model;
import 'package:schoolapp/models/profile/model.dart';

class StudentInformationController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rxn<parent_model.Student> selectedStudent = Rxn<parent_model.Student>();
  final Rxn<parent_model.Parent> parentInfo = Rxn<parent_model.Parent>();
  final RxString selectedChildName = ''.obs;
  final RxString parentProfile = ''.obs;
  final RxBool isTeacherMode = false.obs;
  final RxBool showParentProfile = false.obs;
  final RxString teacherRole = 'N/A'.obs;
  bool get _fromProfileAction =>
      Get.arguments is Map && Get.arguments['fromProfileAction'] == true;

  @override
  void onInit() {
    _bootstrap();
    super.onInit();
  }

  Future<void> _bootstrap() async {
    if (!_fromProfileAction) {
      await _loadCachedSnapshot();
    }
    await fetchStudentInfo();
  }

  Future<void> _loadCachedSnapshot() async {
    try {
      final modeKey =
          (await SharedPreferencesManager.get('student_info_mode') ?? '')
              .toString()
              .trim();
      final currentMode = UserRepository.shared.isParent ? 'parent' : 'teacher';
      if (modeKey.isNotEmpty && modeKey != currentMode) {
        return;
      }
      final cachedName =
          (await SharedPreferencesManager.get('student_info_name') ?? '')
              .toString()
              .trim();
      final cachedId =
          (await SharedPreferencesManager.get('student_info_id') ?? '')
              .toString()
              .trim();
      final cachedProfile =
          (await SharedPreferencesManager.get('student_info_profile') ?? '')
              .toString()
              .trim();
      final cachedProfession =
          (await SharedPreferencesManager.get('student_info_profession') ?? '')
              .toString()
              .trim();

      if (cachedName.isEmpty && cachedId.isEmpty && cachedProfile.isEmpty) {
        return;
      }

      selectedStudent.value = parent_model.Student(
        id: int.tryParse(cachedId),
        admissionNo: cachedId,
        name: cachedName,
        nameKh: cachedName,
        profile: cachedProfile,
        profession: cachedProfession,
      );
    } catch (_) {}
  }

  Future<void> fetchStudentInfo() async {
    final hasCached = selectedStudent.value != null;
    if (!hasCached) {
      isLoading.value = true;
    }
    try {
      isTeacherMode.value = !UserRepository.shared.isParent;
      showParentProfile.value = false;
      if (isTeacherMode.value) {
        teacherRole.value =
            (await SharedPreferencesManager.get('user_role') ?? 'N/A')
                .toString()
                .trim();
        final loginStaffCode =
            (await SharedPreferencesManager.get('staff_code') ?? '')
                .toString()
                .trim();
        final loginName =
            (await SharedPreferencesManager.get('name') ?? '')
                .toString()
                .trim();
        final loginProfile =
            (await SharedPreferencesManager.get('profile') ?? '')
                .toString()
                .trim();

        if (loginStaffCode.isNotEmpty ||
            loginName.isNotEmpty ||
            loginProfile.isNotEmpty) {
          selectedStudent.value = parent_model.Student(
            id: int.tryParse(loginStaffCode),
            admissionNo: loginStaffCode,
            name: loginName,
            nameKh: loginName,
            profile: loginProfile,
            profession: 'Teacher',
          );
        }

        ProfileModel? profile;
        try {
          final res = await Get.find<ApiService>().get(
            EndPoints.profile,
            isShowLoading: false,
          );
          profile = _profileFromResponse(res.data);
        } catch (_) {
          // Ignore and fallback to cached profile.
        }

        profile ??= _safeCachedProfile();
        if (profile == null) {
          if (selectedStudent.value == null) {
            selectedStudent.value = _teacherFromCachedLogin(
              staffCode: loginStaffCode,
              name: loginName,
              profile: loginProfile,
            );
          }
          return;
        }

        selectedStudent.value = parent_model.Student(
          id: profile.id.toInt(),
          admissionNo:
              loginStaffCode.isNotEmpty
                  ? loginStaffCode
                  : profile.id.toString(),
          name: profile.name,
          nameKh: profile.name,
          phone: profile.phone,
          profile: profile.profilePath,
          profession:
              profile.profession.trim().isEmpty ? 'N/A' : profile.profession,
        );
        final apiRole = (profile.type).trim();
        if (apiRole.isNotEmpty && apiRole.toLowerCase() != 'n/a') {
          teacherRole.value = apiRole;
        }
        await _cacheCurrentStudent();
        return;
      }

      bool mappedFromParentProfile = false;
      try {
        final selectedId =
            (await SharedPreferencesManager.get('selected_child_id') ?? '')
                .toString()
                .trim();
        final parentRes = await Get.find<ApiService>().get(
          EndPoints.parentProfile,
          queryParameters:
              selectedId.isEmpty
                  ? null
                  : <String, dynamic>{'student_id': selectedId},
          isShowLoading: false,
        );
        final resData = parentRes.data;
        if (resData is Map) {
          final map = Map<String, dynamic>.from(resData);
          final model = StudentProfileHistory.fromJson(map);
          StudentProfileData? d = model.data;

          final rawData = map['data'];
          if (d == null && rawData is List && rawData.isNotEmpty) {
            final first = rawData.first;
            if (first is Map<String, dynamic>) {
              d = StudentProfileData.fromJson(first);
            } else if (first is Map) {
              d = StudentProfileData.fromJson(Map<String, dynamic>.from(first));
            }
          }
          if (d == null && rawData is Map) {
            final dataMap = Map<String, dynamic>.from(rawData);
            final rawStudent = dataMap['student'];
            if (rawStudent is Map<String, dynamic>) {
              d = StudentProfileData.fromJson(rawStudent);
            } else if (rawStudent is Map) {
              d = StudentProfileData.fromJson(
                Map<String, dynamic>.from(rawStudent),
              );
            } else if (rawStudent is List && rawStudent.isNotEmpty) {
              final first = rawStudent.first;
              if (first is Map<String, dynamic>) {
                d = StudentProfileData.fromJson(first);
              } else if (first is Map) {
                d = StudentProfileData.fromJson(
                  Map<String, dynamic>.from(first),
                );
              }
            }
          }
          // Fallback: direct student object at root.
          d ??=
              _looksLikeStudentProfile(map)
                  ? StudentProfileData.fromJson(map)
                  : null;
          if (d != null && _hasStudentProfileData(d)) {
            selectedStudent.value = parent_model.Student(
              id: d.id,
              classId: d.classId,
              admissionNo: d.admissionNo,
              name: d.fullnameEnglish,
              nameKh: d.fullnameKhmer,
              phone: d.phone,
              profile: d.profile,
              className: d.className,
              dob: d.dob,
              pob: d.pod,
              sex: (d.gender ?? '').trim().isEmpty ? 'N/A' : d.gender,
              parentName: d.teacher,
            );
            mappedFromParentProfile = true;
          }
        }
      } catch (_) {
        // Keep fallback endpoint below.
      }

      if (!mappedFromParentProfile) {
        final res = await Get.find<ApiService>().get(
          EndPoints.parentStudentInfo,
          isShowLoading: false,
        );
        if (res.data is! Map) {
          return;
        }

        final model = parent_model.ParentWithChild.fromJson(
          Map<String, dynamic>.from(res.data),
        );
        parentInfo.value = model.data?.parent;
        parentProfile.value = (model.data?.parent?.profile ?? '').trim();
        final students = model.data?.student ?? const <parent_model.Student>[];
        if (students.isEmpty) {
          selectedStudent.value = null;
          showParentProfile.value = true;
          return;
        }

        final selectedId =
            (await SharedPreferencesManager.get('selected_child_id') ?? '')
                .toString()
                .trim();

        parent_model.Student selected = students.first;
        if (selectedId.isNotEmpty) {
          for (final child in students) {
            if ((child.id?.toString() ?? '').trim() == selectedId) {
              selected = child;
              break;
            }
          }
        }
        selectedStudent.value = selected;
      }

      await _cacheCurrentStudent();
      selectedChildName.value =
          (await SharedPreferencesManager.get('selected_child_name') ?? '')
              .toString()
              .trim();
    } catch (e) {
      if (!isTeacherMode.value &&
          (_fromProfileAction || parentInfo.value != null)) {
        await _loadParentOwnProfile();
      } else {
        ExceptionHandler.handleException(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadParentOwnProfile() async {
    showParentProfile.value = true;
    selectedStudent.value = null;

    parent_model.Parent? parent;
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.parentProfile,
        isShowLoading: false,
      );
      final profile = _profileFromResponse(res.data);
      if (profile != null) {
        parent = _parentFromProfile(profile);
        UserRepository.shared.setProfile(profile);
      }
    } catch (_) {
      // Keep profile screen usable even when the server endpoint fails.
    }

    parent ??= _parentFromCachedProfile();
    parent ??= await _parentFromLocalStorage();
    parentInfo.value = parent;
    parentProfile.value = (parent?.profile ?? '').trim();
  }

  Future<parent_model.Parent?> _parentFromLocalStorage() async {
    final name =
        (await SharedPreferencesManager.get('name') ?? '').toString().trim();
    final profile =
        (await SharedPreferencesManager.get('profile') ?? '').toString().trim();
    if (name.isEmpty && profile.isEmpty) {
      return null;
    }
    return parent_model.Parent(name: name, profile: profile);
  }

  parent_model.Parent? _parentFromCachedProfile() {
    try {
      return _parentFromProfile(UserRepository.shared.profile);
    } catch (_) {}
    return null;
  }

  parent_model.Parent _parentFromProfile(ProfileModel profile) {
    return parent_model.Parent(
      id: profile.id.toInt(),
      name: profile.name,
      phone: profile.phone,
      profile:
          _validText(profile.profilePath)
              ? profile.profilePath
              : profile.profile,
      occupation:
          _validText(profile.profession) ? profile.profession : profile.type,
    );
  }

  bool _validText(String value) {
    final text = value.trim().toLowerCase();
    return text.isNotEmpty && text != 'n/a' && text != 'null';
  }

  Future<void> _cacheCurrentStudent() async {
    final s = selectedStudent.value;
    if (s == null) return;
    await SharedPreferencesManager.setValue(
      'student_info_mode',
      UserRepository.shared.isParent ? 'parent' : 'teacher',
    );
    await SharedPreferencesManager.setValue(
      'student_info_name',
      ((s.nameKh ?? s.name ?? '').trim()),
    );
    await SharedPreferencesManager.setValue(
      'student_info_id',
      ((s.id?.toString() ?? s.admissionNo ?? '').trim()),
    );
    await SharedPreferencesManager.setValue(
      'selected_child_class_id',
      ((s.classId?.toString() ?? '').trim()),
    );
    await SharedPreferencesManager.setValue(
      'student_info_class_id',
      ((s.classId?.toString() ?? '').trim()),
    );
    await SharedPreferencesManager.setValue(
      'student_info_profile',
      ((s.profile ?? '').trim()),
    );
    await SharedPreferencesManager.setValue(
      'student_info_profession',
      ((s.profession ?? '').trim()),
    );
  }

  ProfileModel? _safeCachedProfile() {
    try {
      return UserRepository.shared.profile;
    } catch (_) {
      return null;
    }
  }

  bool _looksLikeStudentProfile(Map<String, dynamic> map) {
    return map['admission_no'] != null ||
        map['student_name'] != null ||
        map['fullname_english'] != null ||
        map['fullname_khmer'] != null ||
        map['class'] != null ||
        map['class_name'] != null;
  }

  bool _hasStudentProfileData(StudentProfileData data) {
    return (data.admissionNo ?? '').trim().isNotEmpty ||
        (data.fullnameEnglish ?? '').trim().isNotEmpty ||
        (data.fullnameKhmer ?? '').trim().isNotEmpty ||
        (data.className ?? '').trim().isNotEmpty ||
        (data.dob ?? '').trim().isNotEmpty;
  }

  ProfileModel? _profileFromResponse(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(raw);
    final candidates = <dynamic>[map['data'], map['user'], map['profile'], map];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        return ProfileModel.fromJson(candidate);
      }
      if (candidate is Map) {
        return ProfileModel.fromJson(Map<String, dynamic>.from(candidate));
      }
    }
    return null;
  }

  parent_model.Student _teacherFromCachedLogin({
    required String staffCode,
    required String name,
    required String profile,
  }) {
    return parent_model.Student(
      id: int.tryParse(staffCode),
      admissionNo: staffCode,
      name: name.isEmpty ? 'N/A' : name,
      nameKh: name.isEmpty ? 'N/A' : name,
      profile: profile,
      profession: 'Teacher',
    );
  }

  String displayName(parent_model.Student student) {
    final nameKh = (student.nameKh ?? '').trim();
    if (nameKh.isNotEmpty) return nameKh;
    final name = (student.name ?? '').trim();
    if (name.isNotEmpty) return name;
    if (UserRepository.shared.isParent &&
        selectedChildName.value.trim().isNotEmpty) {
      return selectedChildName.value.trim();
    }
    return 'N/A';
  }

  String displayClass(parent_model.Student student) {
    final className = (student.className ?? '').trim();
    final section = (student.section ?? '').trim();
    if (className.isEmpty && section.isEmpty) return 'N/A';
    if (className.isNotEmpty && section.isNotEmpty)
      return '$className "$section"';
    return className.isNotEmpty ? className : section;
  }

  String displayCode(parent_model.Student student) {
    final admission = (student.admissionNo ?? '').trim();
    if (admission.isNotEmpty) return admission;
    final id = (student.id?.toString() ?? '').trim();
    return id.isEmpty ? 'N/A' : id;
  }

  String displayPhone(parent_model.Student student) {
    final phone = (student.phone ?? '').trim();
    return phone.isEmpty ? 'N/A' : phone;
  }

  String displayDob(parent_model.Student student) {
    final dob = (student.dob ?? '').trim();
    return dob.isEmpty ? 'N/A' : dob;
  }

  String displayPob(parent_model.Student student) {
    final pob = (student.pob ?? '').trim();
    return pob.isEmpty ? 'N/A' : pob;
  }

  String displaySex(parent_model.Student student) {
    final sex = (student.sex ?? '').trim();
    return sex.isEmpty ? 'N/A' : sex;
  }

  String displayProfession(parent_model.Student student) {
    final profession = (student.profession ?? '').trim();
    final parentOccupation = (parentInfo.value?.occupation ?? '').trim();
    if (profession.isNotEmpty) return profession;
    if (parentOccupation.isNotEmpty) return parentOccupation;
    return 'N/A';
  }

  String displayParent(parent_model.Student student) {
    final parentFromStudent = (student.parentName ?? '').trim();
    final parentFromParent = (parentInfo.value?.name ?? '').trim();
    if (parentFromStudent.isNotEmpty) return parentFromStudent;
    if (parentFromParent.isNotEmpty) return parentFromParent;
    return 'N/A';
  }

  String displayId(parent_model.Student student) {
    final code = (student.admissionNo ?? '').trim();
    if (code.isNotEmpty) return code;
    final id = (student.id?.toString() ?? '').trim();
    return id.isEmpty ? 'N/A' : id;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
