import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations/migration_runner.dart';
import '../models/client.dart';
import '../models/anamnesis.dart';
import '../models/service.dart';

part 'db_helper_anamnesis.dart';
part 'db_helper_clients.dart';
part 'db_helper_services.dart';

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
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createBaseSchema(db);
        await _createAnamnesisSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await DatabaseMigrationRunner.run(db, oldVersion, newVersion);
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
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        procedure TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
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
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
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

}
