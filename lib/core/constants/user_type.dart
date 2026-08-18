enum UserType {
  teacher('teacher'),
  parent('parent'),
  ;

  final String key;
  const UserType(this.key);

  static UserType? fromKey(String? value) {
    if (value == null) return null;
    for (final type in UserType.values) {
      if (type.key == value.toLowerCase()) return type;
    }
    return null;
  }

  static Set<String> get allowedRoleKeys =>
      UserType.values.map((type) => type.key).toSet();
}

