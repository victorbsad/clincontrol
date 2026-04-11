import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
        if (oldVersion < 2) {
          await _createAnamnesisSchema(db);
        }
        if (oldVersion < 3) {
          await _migrateToV3(db);
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

  Future<void> _migrateToV3(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');

    try {
      final clientColumns = await db.rawQuery("PRAGMA table_info(clients)");
      final hasDeletedAt = clientColumns.any((column) => column['name'] == 'deleted_at');

      if (!hasDeletedAt) {
        await db.execute('ALTER TABLE clients ADD COLUMN deleted_at TEXT');
      }

      await db.execute('''
        CREATE TABLE services_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER NOT NULL,
          procedure TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        INSERT INTO services_new (id, client_id, procedure, amount, date)
        SELECT id, client_id, procedure, amount, date
        FROM services
      ''');

      await db.execute('DROP TABLE services');
      await db.execute('ALTER TABLE services_new RENAME TO services');

      final anamnesesTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'anamneses'",
      );

      if (anamnesesTable.isNotEmpty) {
        await db.execute('''
          CREATE TABLE anamneses_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          INSERT INTO anamneses_new (id, client_id, created_at, updated_at)
          SELECT id, client_id, created_at, updated_at
          FROM anamneses
        ''');

        await db.execute('DROP TABLE anamneses');
        await db.execute('ALTER TABLE anamneses_new RENAME TO anamneses');
      }
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }
}
