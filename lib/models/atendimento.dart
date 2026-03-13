class Atendimento {
  int? id;
  int clienteId;
  String procedimento;
  double valor;
  String data;

  Atendimento({
    this.id,
    required this.clienteId,
    required this.procedimento,
    required this.valor,
    required this.data,
  });
}