import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/models.dart';
import 'package:get/get.dart';

class SettingRepository {
  Future<List<ClassModel>> getClasses() async {
    final res = await Get.find<ApiService>().get(
      EndPoints.classes,
      isShowLoading: false,
    );
    final data = res.data;
    if (data is! Map || data['data'] is! List) {
      return const [];
    }
    return ClassModel.listFromJson(data['data'] as List);
  }

  Future<List<SectionModel>> getSections() async {
    final res = await Get.find<ApiService>().get(
      EndPoints.sections,
      isShowLoading: false,
    );
    final data = res.data;
    if (data is! Map || data['data'] is! List) {
      return const [];
    }
    return SectionModel.listFromJson(data['data'] as List);
  }

  Future<List<SubjectModel>> getSubjects() async {
    final res = await Get.find<ApiService>().get(
      EndPoints.subjects,
      isShowLoading: false,
    );
    final data = res.data;
    if (data is! Map || data['data'] is! List) {
      return const [];
    }
    return SubjectModel.listFromJson(data['data'] as List);
  }
}
