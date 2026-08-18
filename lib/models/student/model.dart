class Student {
  final int id;
  final String firstname;
  final String lastname;
  final String image;
  final String className;
  final String sectionName;
  final String profile;

  Student({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.image,
    required this.className,
    required this.sectionName,
    required this.profile,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      image: json['image'] ?? '',
      className: json['class_name'] ?? '',
      sectionName: json['section_name'] ?? '',
      profile: json['profile'] ?? '',
    );
  }
}
