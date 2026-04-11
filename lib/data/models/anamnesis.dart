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
        updatedAt = updatedAt ?? createdAt ?? DateTime.now(),
        answers = answers ?? {};
}

class StoredAnamnesisAnswer {
  final String? textValue;
  final int? intValue;
  final double? realValue;
  final int? boolValue;
  final String? dateValue;
  final String? enumValue;
  final String? jsonValue;
  final String type;

  const StoredAnamnesisAnswer({
    required this.type,
    this.textValue,
    this.intValue,
    this.realValue,
    this.boolValue,
    this.dateValue,
    this.enumValue,
    this.jsonValue,
  });

  Map<String, Object?> toDbMap() {
    return {
      'value_type': type,
      'value_text': textValue,
      'value_int': intValue,
      'value_real': realValue,
      'value_bool': boolValue,
      'value_date': dateValue,
      'value_enum': enumValue,
      'value_json': jsonValue,
    };
  }
}