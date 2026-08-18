class ProfileModel {
  final num id;
  final String name;
  final String email;
  final String profile;
  final String company;
  final String phone;
  final String type;
  final dynamic gender;
  final String emailVerifiedAt;
  final num? status;
  final num? entryBy;
  final dynamic updateBy;
  final dynamic customerId;
  final num? driverId;
  final num? branchId;
  final String createdAt;
  final String updatedAt;
  final String profilePath;
  final String policy;
  final String profession;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profile,
    required this.company,
    required this.phone,
    required this.type,
    required this.gender,
    required this.emailVerifiedAt,
    this.status,
    this.entryBy,
    required this.updateBy,
    required this.customerId,
    this.driverId,
    this.branchId,
    required this.createdAt,
    required this.updatedAt,
    required this.profilePath,
    required this.policy,
    required this.profession,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final profileValue = _firstNonEmpty([
      json['profile_path'],
      json['profile'],
      json['avatar'],
      json['photo'],
      json['image'],
      json['profile_url'],
    ]);

    return ProfileModel(
      id: json['id'] ?? 0,
      name: _asText(json['name'], fallback: 'N/A'),
      email: _asText(json['email'], fallback: 'N/A'),
      profile: profileValue.isEmpty ? 'N/A' : profileValue,
      company: _asText(json['company'], fallback: 'N/A'),
      phone: _asText(json['phone'], fallback: 'N/A'),
      type: _asText(json['type'], fallback: 'N/A'),
      gender: json['gender'] ?? 'N/A',
      emailVerifiedAt: _asText(json['email_verified_at'], fallback: 'N/A'),
      status: json['status'],
      entryBy: json['entry_by'],
      updateBy: json['update_by'] ?? 'N/A',
      customerId: json['customer_id'] ?? 'N/A',
      driverId: json['driver_id'],
      branchId: json['branch_id'],
      createdAt: _asText(json['created_at'], fallback: 'N/A'),
      updatedAt: _asText(json['updated_at'], fallback: 'N/A'),
      profilePath: profileValue.isEmpty ? 'N/A' : profileValue,
      policy: _asText(json['policy'], fallback: 'N/A'),
      profession: _firstNonEmpty([
        json['profession'],
        json['occupation'],
        json['job'],
        json['company'],
      ]),
    );
  }

  static String _asText(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }
    return text;
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = _asText(value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }
}
