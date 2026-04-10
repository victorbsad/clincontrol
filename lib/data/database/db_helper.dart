import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/client.dart';
import '../models/anamnesis.dart';
import '../models/service.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await _createBaseSchema(db);
        await _createAnamnesisSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createAnamnesisSchema(db);
        }
      },
    );
  }

  Future<void> _createBaseSchema(Database db) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        procedure TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id)
      )
    ''');
  }

  Future<void> _createAnamnesisSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS anamneses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS anamnesis_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        anamnesis_id INTEGER NOT NULL,
        field_key TEXT NOT NULL,
        value TEXT NOT NULL,
        value_type TEXT NOT NULL,
        FOREIGN KEY (anamnesis_id) REFERENCES anamneses(id) ON DELETE CASCADE,
        UNIQUE(anamnesis_id, field_key)
      )
    ''');
  }

  // ----------ANAMNESIS----------------------------------------------

  Future<int> insertAnamnesis(Anamnesis anamnesis) async {
    final db = await database;
    final now = (anamnesis.createdAt).toIso8601String();

    return await db.transaction((txn) async {
      final anamnesisId = await txn.insert('anamneses', {
        'client_id': anamnesis.clientId,
        'created_at': now,
        'updated_at': now,
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
      answersByAnamnesisId.putIfAbsent(anamnesisId, () => {});
      answersByAnamnesisId[anamnesisId]![row['field_key'] as String] =
          _decodeStoredValue(row['value'] as String, row['value_type'] as String);
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
      map[row['field_key'] as String] =
          _decodeStoredValue(row['value'] as String, row['value_type'] as String);
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
    final updatedAt = DateTime.now().toIso8601String();

    return await db.transaction((txn) async {
      await txn.update(
        'anamneses',
        {
          'client_id': anamnesis.clientId,
          'updated_at': updatedAt,
        },
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
      await txn.delete('anamnesis_answers', where: 'anamnesis_id = ?', whereArgs: [id]);
      return await txn.delete('anamneses', where: 'id = ?', whereArgs: [id]);
    });
  }

  Iterable<MapEntry<String, StoredAnamnesisAnswer>> _normalizeAnswers(Map<String, dynamic> answers) sync* {
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

  // ----------CLIENTS--------------------------------------------------

  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', {
      'name': client.name,
      'phone': client.phone,
      'notes': client.notes,
    });
  }


  Future<List<Client>> fetchClients() async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query('clients');

    return rows.map((map) => Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      notes: map['notes'],
    )).toList();
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      {
        'name': client.name,
        'phone': client.phone,
        'notes': client.notes,
      },
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── SERVICES ─────────────────────────────────────

  Future<int> insertService(Service service) async {
    final db = await database;
    return await db.insert('services', {
      'client_id': service.clientId,
      'procedure': service.procedure,
      'amount': service.amount,
      'date': service.date,
    });
  }

  Future<double> fetchMonthlyTotal(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM services
      WHERE strftime('%m', date) = ?
      AND strftime('%Y', date) = ?
    ''', [month.toString().padLeft(2, '0'), year.toString()]);

    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> fetchMonthlyCount(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM services
      WHERE strftime('%m', date) = ?
      AND strftime('%Y', date) = ?  
    ''', [month.toString().padLeft(2, '0'), year.toString()]);

    return result.first['count'] as int? ?? 0;
  }

}