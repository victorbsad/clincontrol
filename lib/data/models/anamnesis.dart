class Anamnesis {
  int? id;
  int clientId;
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> answers;

  Anamnesis({
    this.id,
    required this.clientId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? answers,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        answers = answers ?? {};
}

class StoredAnamnesisAnswer {
  final String value;
  final String type;

  const StoredAnamnesisAnswer(this.value, this.type);
}