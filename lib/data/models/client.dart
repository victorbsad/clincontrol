class Client {
  int? id;
  String name;
  String phone;
  String notes;
  DateTime? deletedAt;

  Client({
    this.id,
    required this.name,
    required this.phone,
    required this.notes,
    this.deletedAt,
  });
}