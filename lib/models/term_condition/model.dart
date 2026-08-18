class TermsConditionsModel {
  TermsConditionsModel({
    required this.title,
    required this.version,
    required this.updatedAt,
    required this.content,
  });

  final String title;
  final String version;
  final String updatedAt;
  final String content;

  factory TermsConditionsModel.fromJson(Map<String, dynamic> json) {
    return TermsConditionsModel(
      title: (json['title'] ?? '').toString(),
      version: (json['version'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
    );
  }
}
