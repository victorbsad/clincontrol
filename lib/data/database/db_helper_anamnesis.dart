part of 'db_helper.dart';

extension DbHelperAnamnesisOperations on DbHelper {
  Future<int> insertAnamnesis(Anamnesis anamnesis) async {
    final db = await database;
    final createdAt = anamnesis.createdAt;
    final normalizedUpdatedAt = anamnesis.updatedAt.isBefore(createdAt)
        ? createdAt
        : anamnesis.updatedAt;

    return await db.transaction((txn) async {
      final anamnesisId = await txn.insert('anamneses', {
        'client_id': anamnesis.clientId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': normalizedUpdatedAt.toIso8601String(),
      });

      for (final entry in _normalizeAnswers(anamnesis.answers)) {
        await txn.insert('anamnesis_answers', {
          'anamnesis_id': anamnesisId,
          'field_key': entry.key,
          'value': entry.value.value,
          'value_type': entry.value.type,
        });
      }

      return anamnesisId;
    });
  }

  Future<List<Anamnesis>> fetchAnamnesesByClient(int clientId) async {
    final db = await database;
    final anamnesisRows = await db.query(
      'anamneses',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );

    if (anamnesisRows.isEmpty) return [];

    final ids = anamnesisRows.map((row) => row['id'] as int).toList();
    final answerRows = await db.query(
      'anamnesis_answers',
      where: 'anamnesis_id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );

    final answersByAnamnesisId = <int, Map<String, dynamic>>{};
    for (final row in answerRows) {
      final anamnesisId = row['anamnesis_id'] as int;
      final rawKey = row['field_key'] as String;
      final decodedValue = _decodeStoredValue(
        row['value'] as String,
        row['value_type'] as String,
      );

      answersByAnamnesisId.putIfAbsent(anamnesisId, () => {});
      answersByAnamnesisId[anamnesisId]![rawKey] = decodedValue;
    }

    return anamnesisRows.map((row) {
      final anamnesisId = row['id'] as int;
      return Anamnesis(
        id: anamnesisId,
        clientId: row['client_id'] as int,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        answers: answersByAnamnesisId[anamnesisId] ?? {},
      );
    }).toList();
  }

  Future<Anamnesis?> fetchAnamnesis(int id) async {
    final db = await database;
    final rows = await db.query(
      'anamneses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final answers = await db.query(
      'anamnesis_answers',
      where: 'anamnesis_id = ?',
      whereArgs: [id],
    );

    final map = <String, dynamic>{};
    for (final row in answers) {
      map[row['field_key'] as String] = _decodeStoredValue(
        row['value'] as String,
        row['value_type'] as String,
      );
    }

    final row = rows.first;
    return Anamnesis(
      id: row['id'] as int,
      clientId: row['client_id'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      answers: map,
    );
  }

  Future<int> updateAnamnesis(Anamnesis anamnesis) async {
    if (anamnesis.id == null) {
      throw ArgumentError('Anamnesis ID is required for update');
    }

    final db = await database;
    final updatedAt = anamnesis.updatedAt.toIso8601String();

    return await db.transaction((txn) async {
      await txn.update(
        'anamneses',
        {'client_id': anamnesis.clientId, 'updated_at': updatedAt},
        where: 'id = ?',
        whereArgs: [anamnesis.id],
      );

      await txn.delete(
        'anamnesis_answers',
        where: 'anamnesis_id = ?',
        whereArgs: [anamnesis.id],
      );

      for (final entry in _normalizeAnswers(anamnesis.answers)) {
        await txn.insert('anamnesis_answers', {
          'anamnesis_id': anamnesis.id,
          'field_key': entry.key,
          'value': entry.value.value,
          'value_type': entry.value.type,
        });
      }

      return anamnesis.id!;
    });
  }

  Future<int> deleteAnamnesis(int id) async {
    final db = await database;
    return await db.transaction((txn) async {
      await txn.delete(
        'anamnesis_answers',
        where: 'anamnesis_id = ?',
        whereArgs: [id],
      );
      return await txn.delete('anamneses', where: 'id = ?', whereArgs: [id]);
    });
  }

  Iterable<MapEntry<String, StoredAnamnesisAnswer>> _normalizeAnswers(
    Map<String, dynamic> answers,
  ) sync* {
    for (final entry in answers.entries) {
      final value = entry.value;

      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      if (value is Iterable && value.isEmpty) continue;
      if (value is Map && value.isEmpty) continue;

      if (value is bool) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toString(), 'bool'));
      } else if (value is int) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toString(), 'int'));
      } else if (value is double) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toString(), 'double'));
      } else if (value is DateTime) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toIso8601String(), 'datetime'));
      } else if (value is Iterable) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(jsonEncode(value.toList()), 'json'));
      } else if (value is Map) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(jsonEncode(value), 'json'));
      } else {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toString(), 'text'));
      }
    }
  }

  dynamic _decodeStoredValue(String value, String type) {
    switch (type) {
      case 'bool':
        return value == 'true';
      case 'int':
        return int.tryParse(value);
      case 'double':
        return double.tryParse(value);
      case 'datetime':
        return DateTime.tryParse(value);
      case 'json':
        return jsonDecode(value);
      default:
        return value;
    }
  }
}
