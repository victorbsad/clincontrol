class Service {
  int? id;
  int clientId;
  String procedure;
  double amount;
  String date;

  Service({
    this.id,
    required this.clientId,
    required this.procedure,
    required this.amount,
    required this.date,
  });
}