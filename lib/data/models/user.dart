class AppUser {
  int? id;
  String name;
  String email;
  String passwordHash;
  bool isCurrent;
  DateTime createdAt;
  DateTime updatedAt;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.isCurrent = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();
}
