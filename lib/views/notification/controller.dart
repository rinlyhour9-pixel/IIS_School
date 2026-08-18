import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:schoolapp/core/core.dart';

class NotificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxList<AnnouncementItem> announcements = <AnnouncementItem>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt perPage = 10.obs;
  final RxInt total = 0.obs;

  bool get hasMorePages => currentPage.value < lastPage.value;

  @override
  void onInit() {
    super.onInit();
    refreshNotifications();
  }

  Future<void> refreshNotifications({bool reset = true}) async {
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

      final res = await Get.find<ApiService>().get(
        EndPoints.announcements,
        queryParameters: <String, dynamic>{'page': currentPage.value},
        isShowLoading: false,
      );

      if (res.data is! Map) {
        if (reset) {
          announcements.clear();
        }
        return;
      }

      final root = Map<String, dynamic>.from(res.data as Map);
      final data = root['data'];
      if (data is! Map) {
        if (reset) {
          announcements.clear();
        }
        return;
      }

      final rows = data['data'];
      if (rows is! List) {
        if (reset) {
          announcements.clear();
        }
        return;
      }

      currentPage.value = (data['current_page'] as num?)?.toInt() ?? 1;
      lastPage.value =
          (data['last_page'] as num?)?.toInt() ?? currentPage.value;
      perPage.value = (data['per_page'] as num?)?.toInt() ?? perPage.value;
      total.value = (data['total'] as num?)?.toInt() ?? rows.length;

      final parsed =
          rows
              .whereType<dynamic>()
              .map((row) {
                if (row is Map<String, dynamic>) {
                  return AnnouncementItem.fromJson(row);
                }
                if (row is Map) {
                  return AnnouncementItem.fromJson(
                    Map<String, dynamic>.from(row),
                  );
                }
                return null;
              })
              .whereType<AnnouncementItem>()
              .where((item) => item.title.isNotEmpty || item.image.isNotEmpty)
              .toList();

      if (reset) {
        announcements.assignAll(parsed);
      } else {
        announcements.addAll(
          parsed.where(
            (item) => !announcements.any((existing) => existing.id == item.id),
          ),
        );
      }
    } catch (e) {
      if (reset) {
        announcements.clear();
      }
      ExceptionHandler.handleException(e, alert: false);
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreAnnouncements() async {
    if (!hasMorePages) return;
    currentPage.value += 1;
    await refreshNotifications(reset: false);
  }

  Future<AnnouncementDetailItem?> fetchAnnouncementDetail(int id) async {
    isDetailLoading.value = true;
    try {
      final res = await Get.find<ApiService>().get(
        EndPoints.announcementDetails(id),
        isShowLoading: false,
      );

      if (res.data is! Map) return null;
      final root = Map<String, dynamic>.from(res.data as Map);
      final data = root['data'];
      if (data is! Map) return null;

      return AnnouncementDetailItem.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      ExceptionHandler.handleException(e);
      return null;
    } finally {
      isDetailLoading.value = false;
    }
  }
}

class AnnouncementItem {
  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.image,
    required this.dateText,
  });

  final int id;
  final String title;
  final String image;
  final String dateText;

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString().trim(),
      image: (json['image'] ?? '').toString().trim(),
      dateText: _formatDate(
        json['date'] ??
            json['created_at'] ??
            json['createdAt'] ??
            json['published_at'] ??
            json['publishedAt'] ??
            json['updated_at'] ??
            json['updatedAt'],
      ),
    );
  }

  static String _formatDate(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return DateFormat('dd MMM yyyy').format(parsed);
    }

    final formatters = <DateFormat>[
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy'),
    ];

    for (final formatter in formatters) {
      try {
        return DateFormat('dd MMM yyyy').format(formatter.parseStrict(raw));
      } catch (_) {}
    }

    return raw;
  }
}

class AnnouncementDetailItem {
  const AnnouncementDetailItem({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
  });

  final int id;
  final String title;
  final String image;
  final String description;

  factory AnnouncementDetailItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementDetailItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString().trim(),
      image: (json['image'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
    );
  }
}
