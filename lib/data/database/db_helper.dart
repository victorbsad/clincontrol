import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/anamnesis_field_specs.dart';
import '../models/client.dart';
import '../models/anamnesis.dart';
import '../models/session.dart';

part 'db_helper_anamnesis.dart';
part 'db_helper_clients.dart';
part 'db_helper_sessions.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = kIsWeb
        ? 'clincontrol.db'
        : join(await getDatabasesPath(), 'clincontrol.db');

    return await openDatabase(
      path,
      version: 9,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createBaseSchema(db);
        await _createSessionsSchema(db);
        await _createAnamnesisSchema(db);
      },
    );
  }

  Future<void> _createBaseSchema(Database db) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        notes TEXT,
        marital_status TEXT,
        nationality TEXT,
        address TEXT,
        whatsapp TEXT,
        email TEXT,
        date_of_birth TEXT,
        age TEXT,
        profession TEXT,
        deleted_at TEXT
      )
    ''');
  }

  Future<void> _createSessionsSchema(Database db) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        procedure TEXT NOT NULL,
        notes TEXT,
        amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'AGENDADO',
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
        CHECK (status IN ('AGENDADO', 'PAGO', 'CANCELADO')),
        CHECK (amount >= 0)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_sessions_client_id ON sessions(client_id)',
    );
    await db.execute('CREATE INDEX idx_sessions_date ON sessions(date)');
  }

  Future<void> _createAnamnesisSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS anamneses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS anamnesis_answers (
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
      CREATE TABLE IF NOT EXISTS anamnesis_field_defs (
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
