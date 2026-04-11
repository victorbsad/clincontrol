import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import '../../../core/constants/anamnesis_field_specs.dart';

import 'database_migration.dart';

class MigrationV6RebuildAnamnesisSchema implements DatabaseMigration {
  @override
  int get targetVersion => 6;

  @override
  Future<void> apply(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');

    try {
      await db.execute('DROP TABLE IF EXISTS anamnesis_answers');
      await db.execute('DROP TABLE IF EXISTS anamneses');
      await db.execute('DROP TABLE IF EXISTS anamnesis_field_defs');

      await db.execute('''
        CREATE TABLE anamneses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE anamnesis_answers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          anamnesis_id INTEGER NOT NULL,
          field_key TEXT NOT NULL,
          value_type TEXT NOT NULL,
          value_text TEXT,
          value_int INTEGER,
          value_real REAL,
          value_bool INTEGER,
          value_date TEXT,
          value_enum TEXT,
          value_json TEXT,
          FOREIGN KEY (anamnesis_id) REFERENCES anamneses(id) ON DELETE CASCADE,
          CHECK (value_type IN ('bool', 'int', 'decimal', 'date', 'enum', 'json', 'text')),
          CHECK (value_bool IS NULL OR value_bool IN (0, 1)),
          UNIQUE(anamnesis_id, field_key)
        )
      ''');

      await db.execute('''
        CREATE TABLE anamnesis_field_defs (
          field_key TEXT PRIMARY KEY,
          value_type TEXT NOT NULL,
          is_required INTEGER NOT NULL DEFAULT 0,
          enum_values_json TEXT,
          CHECK (value_type IN ('bool', 'int', 'decimal', 'date', 'enum', 'json', 'text')),
          CHECK (is_required IN (0, 1))
        )
      ''');

      final batch = db.batch();
      for (final key in AnamnesisFieldSpecs.knownKeys) {
        final spec = AnamnesisFieldSpecs.resolve(key);
        final enumJson = spec.enumValues.isEmpty
            ? null
            : jsonEncode(spec.enumValues);

        batch.insert('anamnesis_field_defs', {
          'field_key': key,
          'value_type': _dbTypeFromValueType(spec.valueType),
          'is_required': spec.required ? 1 : 0,
          'enum_values_json': enumJson,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  String _dbTypeFromValueType(AnamnesisValueType valueType) {
    switch (valueType) {
      case AnamnesisValueType.boolean:
        return 'bool';
      case AnamnesisValueType.integer:
        return 'int';
      case AnamnesisValueType.decimal:
        return 'decimal';
      case AnamnesisValueType.date:
        return 'date';
      case AnamnesisValueType.enumValue:
        return 'enum';
      case AnamnesisValueType.json:
        return 'json';
      case AnamnesisValueType.text:
        return 'text';
    }
  }
}
