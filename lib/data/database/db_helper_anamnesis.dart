part of 'db_helper.dart';

extension DbHelperAnamnesisOperations on DbHelper {
  Future<int> insertAnamnesis(Anamnesis anamnesis) async {
    final db = await database;
    final createdAt = anamnesis.createdAt;
    final normalizedUpdatedAt = anamnesis.updatedAt.isBefore(createdAt)
        ? createdAt
        : anamnesis.updatedAt;

    return await db.transaction((txn) async {
      final fieldDefs = await _fetchFieldDefinitions(txn);
      final anamnesisId = await txn.insert('anamneses', {
        'client_id': anamnesis.clientId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': normalizedUpdatedAt.toIso8601String(),
      });

      for (final entry in _normalizeAnswers(anamnesis.answers, fieldDefs)) {
        await txn.insert('anamnesis_answers', {
          'anamnesis_id': anamnesisId,
          'field_key': entry.key,
          ...entry.value.toDbMap(),
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
      final decodedValue = _decodeStoredValue(row);

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
      map[row['field_key'] as String] = _decodeStoredValue(row);
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
      final fieldDefs = await _fetchFieldDefinitions(txn);
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

      for (final entry in _normalizeAnswers(anamnesis.answers, fieldDefs)) {
        await txn.insert('anamnesis_answers', {
          'anamnesis_id': anamnesis.id,
          'field_key': entry.key,
          ...entry.value.toDbMap(),
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
    Map<String, _AnamnesisFieldDefinition> fieldDefinitions,
  ) sync* {
    for (final entry in answers.entries) {
      final fieldDefinition = fieldDefinitions[entry.key];
      if (fieldDefinition == null) {
        throw StateError('Unknown anamnesis key: ${entry.key}');
      }

      final value = entry.value;

      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      if (value is Iterable && value.isEmpty) continue;
      if (value is Map && value.isEmpty) continue;

      yield MapEntry(entry.key, _buildStoredAnswer(fieldDefinition, value));
    }
  }

  dynamic _decodeStoredValue(Map<String, Object?> row) {
    final type = row['value_type'] as String;

    switch (type) {
      case 'bool':
        return (row['value_bool'] as int?) == 1;
      case 'int':
        return row['value_int'] as int?;
      case 'decimal':
        return row['value_real'] as double?;
      case 'date':
        return row['value_date'] as String?;
      case 'enum':
        return row['value_enum'] as String?;
      case 'json':
        final raw = row['value_json'] as String?;
        if (raw == null || raw.isEmpty) return null;
        return jsonDecode(raw);
      default:
        return row['value_text'] as String?;
    }
  }

  StoredAnamnesisAnswer _buildStoredAnswer(
    _AnamnesisFieldDefinition fieldDefinition,
    dynamic value,
  ) {
    switch (fieldDefinition.valueType) {
      case 'bool':
        final boolValue = _coerceBool(value);
        if (boolValue == null) {
          throw StateError(
            'Invalid bool value for ${fieldDefinition.key}: $value',
          );
        }
        return StoredAnamnesisAnswer(
          type: 'bool',
          boolValue: boolValue ? 1 : 0,
        );
      case 'int':
        final intValue = _coerceInt(value);
        if (intValue == null) {
          throw StateError(
            'Invalid int value for ${fieldDefinition.key}: $value',
          );
        }
        return StoredAnamnesisAnswer(type: 'int', intValue: intValue);
      case 'decimal':
        final decimalValue = _coerceDouble(value);
        if (decimalValue == null) {
          throw StateError(
            'Invalid decimal value for ${fieldDefinition.key}: $value',
          );
        }
        return StoredAnamnesisAnswer(type: 'decimal', realValue: decimalValue);
      case 'date':
        final dateValue = _coerceBrazilianDate(value);
        if (dateValue == null) {
          throw StateError(
            'Invalid date value for ${fieldDefinition.key}: $value',
          );
        }
        return StoredAnamnesisAnswer(type: 'date', dateValue: dateValue);
      case 'enum':
        final enumValue = _coerceEnum(value, fieldDefinition.enumValues);
        if (enumValue == null) {
          throw StateError(
            'Invalid enum value for ${fieldDefinition.key}: $value',
          );
        }
        return StoredAnamnesisAnswer(type: 'enum', enumValue: enumValue);
      case 'json':
        if (value is Iterable) {
          return StoredAnamnesisAnswer(
            type: 'json',
            jsonValue: jsonEncode(value.toList()),
          );
        }
        if (value is Map) {
          return StoredAnamnesisAnswer(type: 'json', jsonValue: jsonEncode(value));
        }
        throw StateError('Invalid json value for ${fieldDefinition.key}: $value');
      case 'text':
      default:
        return StoredAnamnesisAnswer(type: 'text', textValue: value.toString());
    }
  }

  Future<Map<String, _AnamnesisFieldDefinition>> _fetchFieldDefinitions(
    DatabaseExecutor db,
  ) async {
    final rows = await db.query('anamnesis_field_defs');
    return {
      for (final row in rows)
        row['field_key'] as String: _AnamnesisFieldDefinition.fromRow(row),
    };
  }

  bool? _coerceBool(dynamic value) {
    if (value is bool) return value;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == 'sim' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == 'nao' || normalized == 'não' || normalized == 'no') {
      return false;
    }
    return null;
  }

  int? _coerceInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString().trim());
  }

  double? _coerceDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }

  String? _coerceBrazilianDate(dynamic value) {
    if (value is DateTime) {
      final day = value.day.toString().padLeft(2, '0');
      final month = value.month.toString().padLeft(2, '0');
      return '$day/$month/${value.year.toString().padLeft(4, '0')}';
    }

    final raw = value.toString().trim();
    final brazilianDate = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (brazilianDate.hasMatch(raw)) {
      return raw;
    }

    final alreadyIso = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (alreadyIso.hasMatch(raw)) {
      final parts = raw.split('-');
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day/$month/${parsed.year.toString().padLeft(4, '0')}';
  }

  String? _coerceEnum(dynamic value, List<String> allowedValues) {
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    for (final allowed in allowedValues) {
      if (allowed.toLowerCase() == raw.toLowerCase()) {
        return allowed;
      }
    }
    return null;
  }
}

class _AnamnesisFieldDefinition {
  final String key;
  final String valueType;
  final List<String> enumValues;

  const _AnamnesisFieldDefinition({
    required this.key,
    required this.valueType,
    required this.enumValues,
  });

  factory _AnamnesisFieldDefinition.fromRow(Map<String, Object?> row) {
    final rawEnumValues = row['enum_values_json'] as String?;
    final enumValues = rawEnumValues == null || rawEnumValues.isEmpty
        ? <String>[]
        : (jsonDecode(rawEnumValues) as List<dynamic>)
              .map((e) => e.toString())
              .toList();

    return _AnamnesisFieldDefinition(
      key: row['field_key'] as String,
      valueType: row['value_type'] as String,
      enumValues: enumValues,
    );
  }
}
