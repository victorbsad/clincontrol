class Client {
  int? id;
  String name;
  String phone;
  String notes;
  String maritalStatus;
  String nationality;
  String address;
  String whatsapp;
  String email;
  String dateOfBirth;
  String age;
  String profession;
  DateTime? deletedAt;

  Client({
    this.id,
    required this.name,
    required this.phone,
    required this.notes,
    this.maritalStatus = '',
    this.nationality = '',
    this.address = '',
    this.whatsapp = '',
    this.email = '',
    this.dateOfBirth = '',
    this.age = '',
    this.profession = '',
    this.deletedAt,
  });
}