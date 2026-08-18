class LoginModel {
  final String? token;
  final String name;
  final String? permission;

  LoginModel({
    required this.token,
    required this.name,
    required this.permission,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      permission: json['permission'] ?? '',
    );
  }
}
