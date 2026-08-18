class ContactUsModel {
  final String englishName;
  final String khmerName;
  final String email;
  final String phone;
  final String address;
  final String website;
  final String facebook;
  final String twitter;
  final String linkedin;
  final String mapUrl;

  ContactUsModel({
    required this.englishName,
    required this.khmerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.website,
    required this.facebook,
    required this.twitter,
    required this.linkedin,
    required this.mapUrl,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      englishName: json['name_en'] ?? 'N/A',
      khmerName: json['name_kh'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      address: json['address'] ?? 'N/A',
      website: json['website'] ?? json['web'] ?? 'www.softcreative.biz',
      facebook: json['facebook'] ?? '',
      twitter: json['twitter'] ?? '',
      linkedin: json['linkedin'] ?? '',
      mapUrl:
          json['map_url'] ??
          json['google_map'] ??
          json['map_link'] ??
          'https://maps.google.com/?q=11.5335286,104.881178',
    );
  }
}
