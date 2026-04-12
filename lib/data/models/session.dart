class Session {
  int? id;
  int clientId;
  String procedure;
  String notes;
  double amount;
  String date;
  DateTime createdAt;
  DateTime updatedAt;

  Session({
    this.id,
    required this.clientId,
    required this.procedure,
    this.notes = '',
    required this.amount,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();
}
