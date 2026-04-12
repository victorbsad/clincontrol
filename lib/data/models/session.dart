class Session {
  static const String statusScheduled = 'AGENDADO';
  static const String statusPaid = 'PAGO';
  static const String statusCanceled = 'CANCELADO';
  static const List<String> allowedStatuses = [
    statusScheduled,
    statusPaid,
    statusCanceled,
  ];

  int? id;
  int clientId;
  String procedure;
  String notes;
  double amount;
  String status;
  String date;
  DateTime createdAt;
  DateTime updatedAt;

  Session({
    this.id,
    required this.clientId,
    required this.procedure,
    this.notes = '',
    required this.amount,
    this.status = statusScheduled,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();
}
